mod handlers;
mod models;
mod proxy;

use actix_cors::Cors;
use actix_files::Files;
use actix_web::{middleware::Logger, web, App, HttpResponse, HttpServer};

// 根路径重定向到 /web/
async fn redirect_to_web() -> HttpResponse {
    HttpResponse::Found()
        .append_header(("Location", "/web/"))
        .finish()
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
            // 静态文件服务
            .service(
                Files::new("/web", "./web")
                    .index_file("index.html")
                    .use_last_modified(true),
            )
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
