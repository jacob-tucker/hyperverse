const {
  createProxyMiddleware,
  responseInterceptor,
} = require("http-proxy-middleware");
module.exports = function (app) {
  app.use(
    "/playground",
    createProxyMiddleware({
      target: "http://localhost:5001",
      changeOrigin: true,
      followRedirects: true,
      selfHandleResponse: true,
      onProxyRes: responseInterceptor(
        async (responseBuffer, proxyRes, req, res) => {
          return responseBuffer;
        }
      ),
    })
  );
  app.use(
    "/flow.access.AccessAPI",
    createProxyMiddleware({
      target: "http://localhost:8080",
      changeOrigin: true,
    })
  );
};
