use tracing::info;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();
    
    info!("Starting Chitinwall server...");
    info!("gRPC listening on :50051");
    info!("Dashboard available at https://localhost:8443");
    
    // TODO: Start gRPC server
    // TODO: Start dashboard server
    
    tokio::signal::ctrl_c().await?;
    info!("Shutting down...");
    
    Ok(())
}
