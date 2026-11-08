import { Router } from "express";

import { pool } from "../db.js";

// GET /health — công khai. Hỏi thử CSDL để biết server VÀ CSDL đều đang sống.
// UptimeRobot gọi đường dẫn này định kỳ để Render không ngủ và Supabase không bị tạm dừng.
export const healthRouter = Router();

healthRouter.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ ok: true, csdl: "ok" });
  } catch {
    res.status(503).json({ ok: false, csdl: "không kết nối được" });
  }
});
