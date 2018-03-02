package com.ee.facebook;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.support.annotation.NonNull;

import com.ee.core.Logger;
import com.ee.core.MessageBridge;
import com.ee.core.MessageHandler;
import com.ee.core.PluginProtocol;
import com.ee.core.internal.Utils;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.model.ShareVideo;
import com.facebook.share.model.ShareVideoContent;
import com.facebook.share.widget.ShareDialog;

import java.io.File;

/**
 * Created by Pham Xuan Han on 17/05/17.
 */
public class Facebook implements PluginProtocol {
    private static final String k__shareLinkContent  = "Facebook_shareLinkContent";
    private static final String k__sharePhotoContent = "Facebook_sharePhotoContent";
    private static final String k__shareVideoContent = "Facebook_shareVideoContent";
    private static final String k__onShareResult     = "Facebook_onShareResult";

    private static final Logger _logger = new Logger(Facebook.class.getName());

    private ShareDialog                     _shareDialog;
    private CallbackManager                 _callbackManager;
    private FacebookCallback<Sharer.Result> _callback;

    public Facebook() {
        Utils.checkMainThread();
        _shareDialog = null;
        _callbackManager = CallbackManager.Factory.create();
        _callback = new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                Utils.checkMainThread();
                MessageBridge bridge = MessageBridge.getInstance();
                bridge.callCpp(k__onShareResult, Utils.toString(true));
            }

            @Override
            public void onCancel() {
                Utils.checkMainThread();
                MessageBridge bridge = MessageBridge.getInstance();
                bridge.callCpp(k__onShareResult, Utils.toString(false));
            }

            @Override
            public void onError(FacebookException error) {
                Utils.checkMainThread();
                MessageBridge bridge = MessageBridge.getInstance();
                bridge.callCpp(k__onShareResult, Utils.toString(false));
            }
        };
        registerHandlers();
    }

    @NonNull
    @Override
    public String getPluginName() {
        return "Facebook";
    }

    @Override
    public void onCreate(@NonNull Activity activity) {
        _shareDialog = new ShareDialog(activity);
        _shareDialog.registerCallback(_callbackManager, _callback);
    }

    @Override
    public void onStart() {
    }

    @Override
    public void onStop() {
    }

    @Override
    public void onResume() {
    }

    @Override
    public void onPause() {
    }

    @Override
    public void onDestroy() {
        _shareDialog = null;
    }

    @Override
    public boolean onBackPressed() {
        return false;
    }

    @Override
    public void destroy() {
        Utils.checkMainThread();
        deregisterHandlers();
    }

    @Override
    public boolean onActivityResult(int requestCode, int responseCode, Intent data) {
        return _callbackManager.onActivityResult(requestCode, responseCode, data);
    }

    private void registerHandlers() {
        MessageBridge bridge = MessageBridge.getInstance();

        bridge.registerHandler(new MessageHandler() {
            @NonNull
            @Override
            public String handle(@NonNull String message) {
                shareLinkContent(message);
                return "";
            }
        }, k__shareLinkContent);

        bridge.registerHandler(new MessageHandler() {
            @NonNull
            @Override
            public String handle(@NonNull String message) {
                sharePhotoContent(message);
                return "";
            }
        }, k__sharePhotoContent);


        bridge.registerHandler(new MessageHandler() {
            @NonNull
            @Override
            public String handle(@NonNull String message) {
                shareVideoContent(message);
                return "";
            }
        }, k__shareVideoContent);
    }

    private void deregisterHandlers() {
        MessageBridge bridge = MessageBridge.getInstance();

        bridge.deregisterHandler(k__shareLinkContent);
        bridge.deregisterHandler(k__sharePhotoContent);
        bridge.deregisterHandler(k__shareVideoContent);
    }

    @SuppressWarnings("WeakerAccess")
    public void shareLinkContent(@NonNull String url) {
        ShareLinkContent shareContent = new ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(url))
                .build();

        _shareDialog.show(shareContent, ShareDialog.Mode.AUTOMATIC);
    }

    @SuppressWarnings("WeakerAccess")
    public void sharePhotoContent(@NonNull String url) {
        Bitmap image = BitmapFactory.decodeFile(url);

        SharePhoto photo = new SharePhoto.Builder()
                .setBitmap(image)
                .build();

        SharePhotoContent shareContent = new SharePhotoContent.Builder()
                .addPhoto(photo)
                .build();

        _shareDialog.show(shareContent, ShareDialog.Mode.AUTOMATIC);
    }

    @SuppressWarnings("WeakerAccess")
    public void shareVideoContent(@NonNull String url) {
        _logger.debug("shareVideoContent: url = " + url);

        File video = new File(url);
        Uri videoFileUri = Uri.fromFile(video);

        ShareVideo videoContent = new ShareVideo.Builder()
                .setLocalUrl(videoFileUri)
                .build();

        ShareVideoContent shareContent = new ShareVideoContent.Builder()
                .setVideo(videoContent)
                .build();

        _shareDialog.show(shareContent, ShareDialog.Mode.AUTOMATIC);
    }
}
