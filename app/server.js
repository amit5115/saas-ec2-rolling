const express = require("express");
const app = express();

const VERSION = process.env.APP_VERSION || "v1";
const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send({
    service: "saas-app",
    version: VERSION,
    status: "running"
  });
});

app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

const server = app.listen(PORT, () => {
  console.log(`App ${VERSION} running on port ${PORT}`);
});

/**
 * Graceful shutdown (mandatory in prod)
 */
process.on("SIGTERM", () => {
  console.log("SIGTERM received, shutting down...");
  server.close(() => {
    process.exit(0);
  });
});
