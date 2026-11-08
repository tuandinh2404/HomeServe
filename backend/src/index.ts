import "dotenv/config"; // đọc .env TRƯỚC mọi import khác
import { app } from "./app.js";

const port = Number(process.env.PORT) || 3000;
app.listen(port, () => console.log(`HomeServe API chạy ở http://localhost:${port}`));
