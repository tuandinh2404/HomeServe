import "dotenv/config";
import pg from "pg";

// Một pool kết nối dùng chung cho cả backend. Mọi route import { pool } từ file này,
// KHÔNG tự tạo new pg.Pool() ở chỗ khác.
export const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }, // Supabase bắt buộc kết nối có SSL
  max: 5, // Session pooler gói Free giới hạn số kết nối; 5 là đủ cho đồ án
});

// Supabase đôi khi cắt kết nối đang rảnh. Không bắt sự kiện này thì cả server bị sập.
pool.on("error", (e) => {
  console.error("Kết nối CSDL rảnh bị lỗi:", e.message);
});

// Chạy nhiều câu SQL trong MỘT transaction: tất cả cùng thành công, hoặc tất cả bị hủy.
// Cách dùng:
//   const kq = await giaoDich(async (client) => {
//     await client.query("INSERT INTO thanh_toan ... ", [...]);
//     await client.query("UPDATE yeu_cau SET trang_thai = 'HOAN_TAT' WHERE id = $1", [id]);
//     return ...;
//   });
// Trong hàm phải dùng client.query (cùng 1 kết nối), KHÔNG dùng pool.query.
export async function giaoDich<T>(viec: (client: pg.PoolClient) => Promise<T>): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const ketQua = await viec(client);
    await client.query("COMMIT");
    return ketQua;
  } catch (e) {
    await client.query("ROLLBACK");
    throw e;
  } finally {
    client.release(); // trả kết nối về pool, quên dòng này là hết kết nối sau vài lần gọi
  }
}
