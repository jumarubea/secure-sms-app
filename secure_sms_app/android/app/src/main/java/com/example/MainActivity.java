package com.example.secure_sms_app;

import android.app.Activity;
import android.app.role.RoleManager;
import android.content.Intent;
import android.os.Build;
import android.provider.Telephony;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "sms_default_channel";
    private static final int REQUEST_CODE_ROLE = 1001;

    private MethodChannel.Result pendingResult;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("requestDefaultSmsApp")) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            RoleManager roleManager = getSystemService(RoleManager.class);
                            if (roleManager.isRoleAvailable(RoleManager.ROLE_SMS) &&
                                    !roleManager.isRoleHeld(RoleManager.ROLE_SMS)) {
                                Intent intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_SMS);
                                pendingResult = result; // Save to return result later
                                startActivityForResult(intent, REQUEST_CODE_ROLE);
                            } else {
                                result.success(true); // Already default or not available
                            }
                        } else {
                            // For Android 9 and below
                            Intent intent = new Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT);
                            intent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, getPackageName());
                            startActivity(intent);
                            result.success(true);
                        }
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_ROLE) {
            if (pendingResult != null) {
                if (resultCode == Activity.RESULT_OK) {
                    // Successfully set as default
                    pendingResult.success(true);
                } else {
                    // User denied
                    pendingResult.success(false);
                }
                pendingResult = null;
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }
}
