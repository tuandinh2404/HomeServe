import express from "express";
import cors from "cors";

import { apiRouter } from "./routes/index.js";
import { khongCoDuongDan, xuLyLoi } from "./loi.js";

// Tạo app Express. Tách khỏi index.ts để sau này viết test gọi thẳng app mà không cần mở cổng.
export const app = express();

app.use(cors());
app.use(express.json({ limit: "1mb" })); // ảnh / video KHÔNG gửi qua JSON, đi qua /tai-len

app.get("/", (_req, res) => {
  res.json({ name: "HomeServe API", version: "0.1.0" });
});

app.use(apiRouter);

// 2 dòng này luôn ở CUỐI: đường dẫn lạ → 404, mọi lỗi → xuLyLoi
app.use(khongCoDuongDan);
app.use(xuLyLoi);
