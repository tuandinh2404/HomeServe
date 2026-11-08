package com.app.homeserve.model;

public class YeuCau {
    public int id;
    public String tenDichVu;
    public String diaChi;
    public String thoiGianMongMuon;
    public String trangThai; // "Chờ nhận", "Đã phân công"...

    public YeuCau(int id, String tenDichVu, String diaChi, String thoiGianMongMuon, String trangThai) {
        this.id = id;
        this.tenDichVu = tenDichVu;
        this.diaChi = diaChi;
        this.thoiGianMongMuon = thoiGianMongMuon;
        this.trangThai = trangThai;
    }
}