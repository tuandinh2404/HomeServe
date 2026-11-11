import { randomUUID } from "node:crypto";
import { Router, raw } from "express";

import { loi } from "../loi.js";
import { canDangNhap } from "../middleware/xacThuc.js";

export const taiLenRouter = Router();

const docFile = raw({
  type: ["image/jpeg", "image/png", "image/webp", "video/mp4"],
  limit: 5 * 1024 * 1024,
  inflate: false,
});

taiLenRouter.post(
  "/tai-len",
  canDangNhap,
  (req, res, next) => {
    docFile(req, res, (err) => {
      if (err) {
        next(
          loi.saiDuLieu(
            "Không đọc được file: tối đa 5 MiB, không gửi dữ liệu nén",
            "file",
          ),
        );
        return;
      }

      next();
    });
  },
  async (req, res) => {
    const mime = (req.get("Content-Type") ?? "")
      .split(";")[0]!
      .trim()
      .toLowerCase();

    const file = req.body;

    if (!Buffer.isBuffer(file) || file.length === 0) {
      throw loi.saiDuLieu(
        "Gửi file binary: JPEG, PNG, WebP hoặc MP4",
        "file",
      );
    }

    // Kiểm tra phần đầu nội dung file.
    let duoi: string | null = null;

    if (
      mime === "image/jpeg" &&
      file.length >= 3 &&
      file.subarray(0, 3).equals(Buffer.from([0xff, 0xd8, 0xff]))
    ) {
      duoi = "jpg";
    }

    if (
      mime === "image/png" &&
      file.length >= 8 &&
      file.subarray(0, 8).equals(
        Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
      )
    ) {
      duoi = "png";
    }

    if (
      mime === "image/webp" &&
      file.length >= 12 &&
      file.toString("ascii", 0, 4) === "RIFF" &&
      file.toString("ascii", 8, 12) === "WEBP"
    ) {
      duoi = "webp";
    }

    if (
      mime === "video/mp4" &&
      file.length >= 16 &&
      file.toString("ascii", 4, 8) === "ftyp"
    ) {
      const nhan = file.toString("ascii", 8, 12);

      if (
        ["isom", "iso2", "mp41", "mp42", "avc1", "M4V "].includes(nhan)
      ) {
        duoi = "mp4";
      }
    }

    if (!duoi) {
      throw loi.saiDuLieu(
        "Nội dung file không khớp định dạng được hỗ trợ",
        "file",
      );
    }

    const supabaseUrl = process.env.SUPABASE_URL?.replace(/\/+$/, "");
    const khoa = process.env.SUPABASE_SERVICE_KEY;

    if (!supabaseUrl || !khoa) {
      throw new Error("Thiếu cấu hình Supabase Storage");
    }

    const bucket = "yeu-cau-media";
    const duongDan = `${req.nguoiDung!.id}/${randomUUID()}.${duoi}`;

    const phanHoi = await fetch(
      `${supabaseUrl}/storage/v1/object/${bucket}/${duongDan}`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${khoa}`,
          apikey: khoa,
          "Content-Type": mime,
          "x-upsert": "false",
        },
        body: new Uint8Array(file),
        signal: AbortSignal.timeout(30000),
      },
    );

    if (!phanHoi.ok) {
      console.error("Tải Storage thất bại, HTTP:", phanHoi.status);
      throw new Error("Không tải được file lên Storage");
    }

    res.status(201).json({
      url: `${supabaseUrl}/storage/v1/object/public/${bucket}/${duongDan}`,
      loai: mime,
      dung_luong: file.length,
    });
  },
);