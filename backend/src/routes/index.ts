import { Router } from "express";

import { healthRouter } from "./health.js";
import { authRouter } from "./auth.js";
import { danhMucRouter } from "./danhMuc.js";
import { dichVuRouter } from "./dichVu.js";
import { hoSoThoRouter } from "./hoSoTho.js";
import { yeuCauRouter } from "./yeuCau.js";
import { phanCongRouter } from "./phanCong.js";
import { baoGiaRouter } from "./baoGia.js";
import { thanhToanRouter } from "./thanhToan.js";
import { taiLenRouter } from "./taiLen.js";
import { danhGiaRouter } from "./danhGia.js";
import { khieuNaiRouter } from "./khieuNai.js";
import { baoCaoRouter } from "./baoCao.js";

// Gom mọi router lại một chỗ. Mỗi tính năng 1 file trong routes/, mỗi người sửa file của mình.
// Đường dẫn đầy đủ viết NGAY TRONG từng file (vd danhMucRouter.get("/danh-muc-dv", ...)),
// để tìm trong code là thấy đúng đường dẫn như api.md.
// Lưu ý: import trong dự án này phải có đuôi ".js" (TypeScript + "module": "nodenext").
export const apiRouter = Router();

apiRouter.use(healthRouter);
apiRouter.use(authRouter);
apiRouter.use(danhMucRouter);
apiRouter.use(dichVuRouter);
apiRouter.use(hoSoThoRouter);
apiRouter.use(yeuCauRouter);
apiRouter.use(phanCongRouter);
apiRouter.use(baoGiaRouter);
apiRouter.use(thanhToanRouter);
apiRouter.use(taiLenRouter);
apiRouter.use(danhGiaRouter);
apiRouter.use(khieuNaiRouter);
apiRouter.use(baoCaoRouter);
