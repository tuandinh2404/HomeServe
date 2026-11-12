import { Router } from "express";

import { pool, giaoDich } from "../db.js";
import { loi } from "../loi.js";
import { canDangNhap, chiCho } from "../middleware/xacThuc.js";

export const phanCongRouter = Router();

phanCongRouter.get(
  "/yeu-cau/:id/tho-phu-hop",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0 || id > 2147483647) {
      throw loi.saiDuLieu("ID yêu cầu phải là số nguyên dương", "id");
    }

    const yeuCau = await pool.query(
      `SELECT yc.khu_vuc_id, dv.danh_muc_id
       FROM yeu_cau yc
       JOIN dich_vu dv ON dv.id = yc.dich_vu_id
       WHERE yc.id = $1`,
      [id],
    );

    if (yeuCau.rows.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy yêu cầu" });
    }

    const { khu_vuc_id, danh_muc_id } = yeuCau.rows[0];
    const tho = await pool.query(
      `SELECT hs.nguoi_dung_id AS tho_id, nd.ho_ten, hs.diem_tb, hs.so_viec
       FROM ho_so_tho hs
       JOIN nguoi_dung nd ON nd.id = hs.nguoi_dung_id
       WHERE hs.nghe_id = $1
         AND hs.khu_vuc_id = $2
         AND hs.trang_thai_duyet = 'DA_DUYET'
       ORDER BY hs.diem_tb DESC, hs.nguoi_dung_id ASC`,
      [danh_muc_id, khu_vuc_id],
    );

    res.json(tho.rows);
  },
);

phanCongRouter.patch(
  "/yeu-cau/:id/phan-cong",
  canDangNhap,
  chiCho("QUAN_TRI"),
  async (req, res) => {
    const yeuCauId = Number(req.params.id);
    const thoId = req.body?.tho_id;

    if (!Number.isInteger(yeuCauId) || yeuCauId <= 0 || yeuCauId > 2147483647) {
      throw loi.saiDuLieu("Mã yêu cầu phải là số nguyên dương", "id");
    }

    if (!Number.isInteger(thoId) || thoId <= 0 || thoId > 2147483647) {
      throw loi.saiDuLieu("Mã thợ phải là số nguyên dương", "tho_id");
    }

    const phanCong = await giaoDich(async (client) => {
      const { rows: [yeuCau] } = await client.query(
        `SELECT yc.trang_thai, yc.khu_vuc_id, dv.danh_muc_id
         FROM yeu_cau yc
         JOIN dich_vu dv ON dv.id = yc.dich_vu_id
         WHERE yc.id = $1
         FOR UPDATE OF yc`,
        [yeuCauId],
      );

      if (!yeuCau) {
        throw loi.khongTimThay("Không tìm thấy yêu cầu");
      }

      if (yeuCau.trang_thai !== "CHO_NHAN") {
        throw loi.xungDot("Yêu cầu phải ở trạng thái chờ nhận để giao việc");
      }

      const daGiao = await client.query(
        `SELECT 1 FROM phan_cong
         WHERE yeu_cau_id = $1
           AND trang_thai IN ('CHO_THO_NHAN', 'DA_NHAN')`,
        [yeuCauId],
      );

      if (daGiao.rows.length > 0) {
        throw loi.xungDot("Yêu cầu này đã được giao cho thợ");
      }

      const tho = await client.query(
        `SELECT 1 FROM ho_so_tho
         WHERE nguoi_dung_id = $1
           AND nghe_id = $2
           AND khu_vuc_id = $3
           AND trang_thai_duyet = 'DA_DUYET'
         FOR SHARE`,
        [thoId, yeuCau.danh_muc_id, yeuCau.khu_vuc_id],
      );

      if (tho.rows.length === 0) {
        throw loi.saiDuLieu("Thợ chưa được duyệt hoặc không phù hợp", "tho_id");
      }

      const { rows: [ketQua] } = await client.query(
        `INSERT INTO phan_cong (yeu_cau_id, tho_id)
         VALUES ($1, $2)
         RETURNING id, yeu_cau_id, tho_id, trang_thai`,
        [yeuCauId, thoId],
      );

      return ketQua;
    });

    res.status(201).json(phanCong);
  },
);

// 1. Thợ xem danh sách việc được giao cho mình.
phanCongRouter.get(
  "/tho/toi/viec",
  canDangNhap,
  chiCho("THO"),
  async (req, res) => {
    const thoId = req.nguoiDung!.id;

    const { rows } = await pool.query(
      `SELECT pc.id AS phan_cong_id,
              pc.yeu_cau_id,
              pc.trang_thai AS trang_thai_phan_cong,
              pc.thoi_gian_du_kien_toi,
              pc.phan_cong_luc,
              yc.trang_thai AS trang_thai_yeu_cau,
              yc.mo_ta,
              yc.dia_chi,
              yc.thoi_gian_mong_muon
       FROM phan_cong pc
       JOIN yeu_cau yc ON yc.id = pc.yeu_cau_id
       WHERE pc.tho_id = $1
       ORDER BY pc.phan_cong_luc DESC, pc.id DESC`,
      [thoId],
    );

    res.json(rows);
  },
);

// 2. Thợ nhận hoặc từ chối lượt phân công của mình.
phanCongRouter.patch(
  "/phan-cong/:id/nhan",
  canDangNhap,
  chiCho("THO"),
  async (req, res) => {
    const phanCongId = Number(req.params.id);
    const thoId = req.nguoiDung!.id;
    const { chap_nhan, thoi_gian_du_kien_toi } = req.body ?? {};

    if (!Number.isInteger(phanCongId) || phanCongId <= 0 || phanCongId > 2147483647) {
      throw loi.saiDuLieu("Mã phân công phải là số nguyên dương", "id");
    }

    if (typeof chap_nhan !== "boolean") {
      throw loi.saiDuLieu("Chọn true để nhận hoặc false để từ chối", "chap_nhan");
    }

    let duKienToi: string | null = null;

    if (chap_nhan) {
      if (
        typeof thoi_gian_du_kien_toi !== "string" ||
        !Number.isFinite(Date.parse(thoi_gian_du_kien_toi))
      ) {
        throw loi.saiDuLieu(
          "Nhập thời gian dự kiến tới hợp lệ",
          "thoi_gian_du_kien_toi",
        );
      }

      duKienToi = new Date(thoi_gian_du_kien_toi).toISOString();
    }

    const phanCong = await giaoDich(async (client) => {
      // Khóa yêu cầu trước, theo cùng thứ tự với bước giao việc.
      const { rows: [yeuCau] } = await client.query(
        `SELECT yc.id, yc.trang_thai
         FROM yeu_cau yc
         JOIN phan_cong pc ON pc.yeu_cau_id = yc.id
         WHERE pc.id = $1 AND pc.tho_id = $2
         FOR UPDATE OF yc`,
        [phanCongId, thoId],
      );

      if (!yeuCau) {
        throw loi.khongTimThay("Không tìm thấy lượt phân công của bạn");
      }

      if (yeuCau.trang_thai !== "CHO_NHAN") {
        throw loi.xungDot("Yêu cầu không còn ở trạng thái chờ nhận");
      }

      const { rows: [ketQua] } = await client.query(
        `UPDATE phan_cong
         SET trang_thai = $3,
             thoi_gian_du_kien_toi = $4,
             nhan_luc = now()
         WHERE id = $1 AND tho_id = $2
           AND trang_thai = 'CHO_THO_NHAN'
         RETURNING id, yeu_cau_id, tho_id, trang_thai,
                   thoi_gian_du_kien_toi, nhan_luc`,
        [phanCongId, thoId, chap_nhan ? "DA_NHAN" : "TU_CHOI", duKienToi],
      );

      if (!ketQua) {
        throw loi.xungDot("Bạn đã trả lời lượt phân công này");
      }

      if (chap_nhan) {
        await client.query(
          "UPDATE yeu_cau SET trang_thai = 'DA_NHAN' WHERE id = $1",
          [yeuCau.id],
        );
      }

      return ketQua;
    });

    res.json(phanCong);
  },
);

// 3. Thợ đã nhận việc chuyển yêu cầu sang đang làm.
phanCongRouter.patch(
  "/yeu-cau/:id/trang-thai",
  canDangNhap,
  chiCho("THO"),
  async (req, res) => {
    const yeuCauId = Number(req.params.id);
    const thoId = req.nguoiDung!.id;

    if (!Number.isInteger(yeuCauId) || yeuCauId <= 0 || yeuCauId > 2147483647) {
      throw loi.saiDuLieu("Mã yêu cầu phải là số nguyên dương", "id");
    }

    if (req.body?.trang_thai !== "DANG_LAM") {
      throw loi.saiDuLieu("Trạng thái cần gửi là DANG_LAM", "trang_thai");
    }

    const yeuCau = await giaoDich(async (client) => {
      const { rows: [don] } = await client.query(
        `SELECT yc.id, yc.trang_thai
         FROM yeu_cau yc
         WHERE yc.id = $1
           AND EXISTS (
             SELECT 1 FROM phan_cong pc
             WHERE pc.yeu_cau_id = yc.id
               AND pc.tho_id = $2
               AND pc.trang_thai = 'DA_NHAN'
           )
         FOR UPDATE OF yc`,
        [yeuCauId, thoId],
      );

      if (!don) {
        throw loi.khongTimThay("Không tìm thấy yêu cầu bạn đã nhận");
      }

      if (don.trang_thai !== "DA_NHAN") {
        throw loi.xungDot("Chỉ yêu cầu đã nhận mới chuyển sang đang làm");
      }

      const { rows: [ketQua] } = await client.query(
        `UPDATE yeu_cau
         SET trang_thai = 'DANG_LAM'
         WHERE id = $1
         RETURNING id, trang_thai`,
        [yeuCauId],
      );

      return ketQua;
    });

    res.json(yeuCau);
  },
);