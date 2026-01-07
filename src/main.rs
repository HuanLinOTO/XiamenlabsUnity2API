mod handlers;
mod models;
mod proxy;

use actix_cors::Cors;
use actix_web::{middleware::Logger, web, App, HttpResponse, HttpServer, Responder};
use mime_guess::MimeGuess;
use rust_embed::RustEmbed;

// 根路径重定向到 /web/
async fn redirect_to_web() -> HttpResponse {
    HttpResponse::Found()
        .append_header(("Location", "/web/"))
        .finish()
}

// 将 web 目录打包到二进制
#[derive(RustEmbed)]
#[folder = "web"]
struct WebAssets;

async fn embedded_web(path: web::Path<String>) -> impl Responder {
    let mut path = path.into_inner();

    // 支持 /web 和 /web/ 以及嵌套目录默认 index.html
    if path.is_empty() || path.ends_with('/') {
        path.push_str("index.html");
    }

    match WebAssets::get(&path) {
        Some(content) => {
            let mime = MimeGuess::from_path(&path).first_or_octet_stream();
            HttpResponse::Ok()
                .content_type(mime.as_ref())
                .body(content.data.into_owned())
        }
        None => HttpResponse::NotFound().body("Not Found"),
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    log::info!("Starting XiamenLabs OpenAI Proxy Server on 0.0.0.0:8080");
    log::info!("Web UI available at: http://localhost:8080/");
    log::info!("API endpoints at: http://localhost:8080/v1/");

    HttpServer::new(|| {
        let cors = Cors::permissive();

        App::new()
            .wrap(Logger::default())
            .wrap(cors)
            // API 路由
            .route("/v1/models", web::get().to(handlers::list_models))
            .route(
                "/v1/chat/completions",
                web::post().to(handlers::chat_completions),
            )
            // 根路径重定向
            .route("/", web::get().to(redirect_to_web))
            // Web UI 静态资源（嵌入式）
            .route("/web", web::get().to(|| async {
                HttpResponse::Found()
                    .append_header(("Location", "/web/"))
                    .finish()
            }))
            .route("/web/{path:.*}", web::get().to(embedded_web))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
