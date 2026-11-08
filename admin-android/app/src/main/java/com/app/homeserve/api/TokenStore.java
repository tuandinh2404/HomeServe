package com.app.homeserve.api;

import android.content.Context;
import android.content.SharedPreferences;

public class TokenStore {
    public static String layToken(Context ctx) {
        SharedPreferences prefs = ctx.getSharedPreferences("app_prefs", Context.MODE_PRIVATE);
        return prefs.getString("token", null);
    }

    public static void luuToken(Context ctx, String token) {
        SharedPreferences prefs = ctx.getSharedPreferences("app_prefs", Context.MODE_PRIVATE);
        prefs.edit().putString("token", token).apply();
    }
}