package com.app.homeserve.model;

import com.google.gson.annotations.SerializedName;

public class LoginResponse {
    @SerializedName("token")
    private String token;

    @SerializedName("role")
    private String role;

    @SerializedName("message")
    private String message;

    public String getToken() { return token; }
    public String getRole() { return role; }
    public String getMessage() { return message; }
}