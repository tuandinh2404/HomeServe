package com.app.homeserve.models;

public class KetQuaDangNhap {
    public String token;
    public NguoiDung nguoiDung;

    public static class NguoiDung {
        public int id;
        public String hoTen;
        public String vaiTro;
    }
}