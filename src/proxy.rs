use actix_web::web::Bytes;
use anyhow::{anyhow, Result};
use futures_util::stream::{Stream, StreamExt};
use reqwest::Client;
use std::pin::Pin;
use std::sync::OnceLock;
use std::time::{SystemTime, UNIX_EPOCH};

use crate::models::{
    ChatCompletionChunk, ChatCompletionRequest, ChatCompletionResponse, ChatMessage, Choice,
    ChunkChoice, Delta, Usage, XiamenLabsRequest,
};

const XIAMENLABS_API_URL: &str = "https://xiamenlabs.com/api/chat/";
const PROMPT_FILE_PATH: &str = "prompt.md";

// 使用 OnceLock 缓存 prompt 内容，避免重复读取文件
static PROMPT_CACHE: OnceLock<String> = OnceLock::new();

/// 读取 prompt.md 文件内容，如果文件不存在则返回空字符串
fn load_prompt() -> String {
    PROMPT_CACHE
        .get_or_init(|| match std::fs::read_to_string(PROMPT_FILE_PATH) {
            Ok(content) => {
                log::info!(
                    "Loaded prompt from {}: {} characters",
                    PROMPT_FILE_PATH,
                    content.len()
                );
                content
            }
            Err(e) => {
                log::warn!(
                    "Failed to load prompt from {}: {}. Using empty prompt.",
                    PROMPT_FILE_PATH,
                    e
                );
                String::new()
            }
        })
        .clone()
}

/// 增强消息列表，在 system prompt 中插入自定义内容
fn enhance_messages(mut messages: Vec<ChatMessage>) -> Vec<ChatMessage> {
    let prompt_content = load_prompt();

    // 如果 prompt 为空，直接返回原消息
    if prompt_content.trim().is_empty() {
        return messages;
    }

    // 查找第一个 system 消息
    if let Some(system_msg) = messages.iter_mut().find(|m| m.role == "system") {
        // 在现有 system 消息前面插入 prompt
        system_msg.content = format!("{}\n\n{}", prompt_content, system_msg.content);
        log::debug!("Enhanced existing system message");
    } else {
        // 如果没有 system 消息，在开头插入一个
        messages.insert(
            0,
            ChatMessage {
                role: "system".to_string(),
                content: prompt_content,
            },
        );
        log::debug!("Added new system message with prompt");
    }

    messages
}

pub async fn proxy_stream_request(
    req: ChatCompletionRequest,
) -> Result<Pin<Box<dyn Stream<Item = Result<Bytes, actix_web::Error>> + Send>>> {
    let client = Client::new();

    // 增强消息（插入 prompt）
    let enhanced_messages = enhance_messages(req.messages.clone());

    // 转换为 XiamenLabs 格式
    let xiamenlabs_req = XiamenLabsRequest {
        model: req.model.clone(),
        messages: enhanced_messages,
        stream: true,
    };

    let response = client
        .post(XIAMENLABS_API_URL)
        .header("accept", "*/*")
        .header(
            "accept-language",
            "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
        )
        .header("cache-control", "no-cache")
        .header("content-type", "application/json")
        .header("pragma", "no-cache")
        .header("priority", "u=1, i")
        .header(
            "sec-ch-ua",
            "\"Microsoft Edge\";v=\"143\", \"Chromium\";v=\"143\", \"Not A(Brand\";v=\"24\"",
        )
        .header("sec-ch-ua-mobile", "?0")
        .header("sec-ch-ua-platform", "\"Windows\"")
        .header("sec-fetch-dest", "empty")
        .header("sec-fetch-mode", "cors")
        .header("sec-fetch-site", "same-origin")
        .header("Referer", "https://xiamenlabs.com/")
        .json(&xiamenlabs_req)
        .send()
        .await
        .map_err(|e| anyhow!("Failed to send request: {}", e))?;

    if !response.status().is_success() {
        return Err(anyhow!(
            "XiamenLabs API returned error: {}",
            response.status()
        ));
    }

    let model = req.model.clone();
    let stream = response.bytes_stream();

    let converted_stream = stream.map(move |chunk_result| {
        match chunk_result {
            Ok(chunk) => {
                // 处理 SSE 格式的数据
                let text = String::from_utf8_lossy(&chunk);
                let mut output = String::new();

                for line in text.lines() {
                    if line.starts_with("data: ") {
                        let data = &line[6..];

                        if data == "[DONE]" {
                            output.push_str("data: [DONE]\n\n");
                            continue;
                        }

                        // 尝试解析 XiamenLabs 的响应并转换为 OpenAI 格式
                        if let Ok(chunk_data) = serde_json::from_str::<serde_json::Value>(data) {
                            let created = SystemTime::now()
                                .duration_since(UNIX_EPOCH)
                                .unwrap()
                                .as_secs();

                            // 检查是否是内容块
                            if let Some(content) =
                                chunk_data.get("content").and_then(|v| v.as_str())
                            {
                                let openai_chunk = ChatCompletionChunk {
                                    id: format!("chatcmpl-{}", uuid::Uuid::new_v4()),
                                    object: "chat.completion.chunk".to_string(),
                                    created,
                                    model: model.clone(),
                                    choices: vec![ChunkChoice {
                                        index: 0,
                                        delta: Delta {
                                            role: None,
                                            content: Some(content.to_string()),
                                        },
                                        finish_reason: None,
                                    }],
                                };

                                if let Ok(json) = serde_json::to_string(&openai_chunk) {
                                    output.push_str(&format!("data: {}\n\n", json));
                                }
                            } else if chunk_data.get("finish_reason").is_some() {
                                // 结束标记
                                let openai_chunk = ChatCompletionChunk {
                                    id: format!("chatcmpl-{}", uuid::Uuid::new_v4()),
                                    object: "chat.completion.chunk".to_string(),
                                    created,
                                    model: model.clone(),
                                    choices: vec![ChunkChoice {
                                        index: 0,
                                        delta: Delta {
                                            role: None,
                                            content: None,
                                        },
                                        finish_reason: Some("stop".to_string()),
                                    }],
                                };

                                if let Ok(json) = serde_json::to_string(&openai_chunk) {
                                    output.push_str(&format!("data: {}\n\n", json));
                                }
                            }
                        }
                    }
                }

                if output.is_empty() {
                    // 如果没有解析出内容，原样返回
                    Ok(Bytes::from(chunk.to_vec()))
                } else {
                    Ok(Bytes::from(output))
                }
            }
            Err(e) => Err(actix_web::error::ErrorInternalServerError(format!(
                "Stream error: {}",
                e
            ))),
        }
    });

    Ok(Box::pin(converted_stream))
}

pub async fn proxy_non_stream_request(
    req: ChatCompletionRequest,
) -> Result<ChatCompletionResponse> {
    let client = Client::new();

    // 增强消息（插入 prompt）
    let enhanced_messages = enhance_messages(req.messages.clone());

    // 转换为 XiamenLabs 格式
    let xiamenlabs_req = XiamenLabsRequest {
        model: req.model.clone(),
        messages: enhanced_messages,
        stream: false,
    };

    let response = client
        .post(XIAMENLABS_API_URL)
        .header("accept", "*/*")
        .header(
            "accept-language",
            "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
        )
        .header("cache-control", "no-cache")
        .header("content-type", "application/json")
        .header("pragma", "no-cache")
        .header("priority", "u=1, i")
        .header(
            "sec-ch-ua",
            "\"Microsoft Edge\";v=\"143\", \"Chromium\";v=\"143\", \"Not A(Brand\";v=\"24\"",
        )
        .header("sec-ch-ua-mobile", "?0")
        .header("sec-ch-ua-platform", "\"Windows\"")
        .header("sec-fetch-dest", "empty")
        .header("sec-fetch-mode", "cors")
        .header("sec-fetch-site", "same-origin")
        .header("Referer", "https://xiamenlabs.com/")
        .json(&xiamenlabs_req)
        .send()
        .await
        .map_err(|e| anyhow!("Failed to send request: {}", e))?;

    if !response.status().is_success() {
        return Err(anyhow!(
            "XiamenLabs API returned error: {}",
            response.status()
        ));
    }

    let response_data: serde_json::Value = response
        .json()
        .await
        .map_err(|e| anyhow!("Failed to parse response: {}", e))?;

    // 转换为 OpenAI 格式
    let created = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();

    let content = response_data
        .get("content")
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();

    let openai_response = ChatCompletionResponse {
        id: format!("chatcmpl-{}", uuid::Uuid::new_v4()),
        object: "chat.completion".to_string(),
        created,
        model: req.model.clone(),
        choices: vec![Choice {
            index: 0,
            message: ChatMessage {
                role: "assistant".to_string(),
                content,
            },
            finish_reason: Some("stop".to_string()),
        }],
        usage: Usage {
            prompt_tokens: 0,
            completion_tokens: 0,
            total_tokens: 0,
        },
    };

    Ok(openai_response)
}
