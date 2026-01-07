use actix_web::{web, HttpResponse, HttpRequest};
use crate::models::{ChatCompletionRequest, ModelsResponse, Model};
use crate::proxy;

pub async fn list_models() -> HttpResponse {
    let response = ModelsResponse {
        object: "list".to_string(),
        data: vec![
            Model {
                id: "x".to_string(),
                object: "model".to_string(),
                created: 1700000000,
                owned_by: "xiamenlabs".to_string(),
            },
        ],
    };

    HttpResponse::Ok().json(response)
}

pub async fn chat_completions(
    _req: HttpRequest,
    body: web::Json<ChatCompletionRequest>,
) -> HttpResponse {
    log::info!("Received chat completion request: stream={}", body.stream);
    
    if body.stream {
        match proxy::proxy_stream_request(body.into_inner()).await {
            Ok(stream) => HttpResponse::Ok()
                .content_type("text/event-stream")
                .streaming(stream),
            Err(e) => {
                log::error!("Stream proxy error: {}", e);
                HttpResponse::InternalServerError().json(serde_json::json!({
                    "error": {
                        "message": format!("Proxy error: {}", e),
                        "type": "proxy_error",
                        "code": "internal_error"
                    }
                }))
            }
        }
    } else {
        match proxy::proxy_non_stream_request(body.into_inner()).await {
            Ok(response) => HttpResponse::Ok().json(response),
            Err(e) => {
                log::error!("Non-stream proxy error: {}", e);
                HttpResponse::InternalServerError().json(serde_json::json!({
                    "error": {
                        "message": format!("Proxy error: {}", e),
                        "type": "proxy_error",
                        "code": "internal_error"
                    }
                }))
            }
        }
    }
}
