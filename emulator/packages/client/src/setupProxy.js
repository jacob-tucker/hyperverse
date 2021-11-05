const {
  createProxyMiddleware,
  responseInterceptor,
} = require("http-proxy-middleware");
const cors = require('cors');
module.exports = function (app) {
  app.use(cors());
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
