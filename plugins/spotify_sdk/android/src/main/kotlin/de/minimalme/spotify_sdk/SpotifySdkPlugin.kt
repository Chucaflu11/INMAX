package de.minimalme.spotify_sdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import com.spotify.android.appremote.api.ConnectionParams
import com.spotify.android.appremote.api.Connector.ConnectionListener
import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.android.appremote.api.error.*
import com.spotify.sdk.android.auth.AuthorizationClient
import com.spotify.sdk.android.auth.AuthorizationRequest
import com.spotify.sdk.android.auth.AuthorizationResponse
import de.minimalme.spotify_sdk.subscriptions.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.event.SetEvent
import kotlinx.event.event

class SpotifySdkPlugin : MethodCallHandler, FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener {

    private var applicationContext: Context? = null
    private var applicationActivity: Activity? = null
    private var methodChannel: MethodChannel? = null

    private val channelName = "spotify_sdk"
    private val loggingTag = "spotify_sdk"

    private var playerContextChannel: EventChannel? = null
    private var playerStateChannel: EventChannel? = null
    private var capabilitiesChannel: EventChannel? = null
    private var userStatusChannel: EventChannel? = null
    private var connectionStatusChannel: EventChannel? = null

    private val playerContextSubscription = "player_context_subscription"
    private val playerStateSubscription = "player_state_subscription"
    private val capabilitiesSubscription = "capabilities_subscription"
    private val userStatusSubscription = "user_status_subscription"
    private val connectionStatusSubscription = "connection_status_subscription"

    private val methodConnectToSpotify = "connectToSpotify"
    private val methodGetAccessToken = "getAccessToken"
    private val methodDisconnectFromSpotify = "disconnectFromSpotify"
    private val methodGetCrossfadeState = "getCrossfadeState"
    private val methodGetPlayerState = "getPlayerState"
    private val methodPlay = "play"
    private val methodPause = "pause"
    private val methodQueueTrack = "queueTrack"
    private val methodResume = "resume"
    private val methodSeekToRelativePosition = "seekToRelativePosition"
    private val methodSetPodcastPlaybackSpeed = "setPodcastPlaybackSpeed"
    private val methodSkipNext = "skipNext"
    private val methodSkipPrevious = "skipPrevious"
    private val methodSkipToIndex = "skipToIndex"
    private val methodSeekTo = "seekTo"
    private val methodToggleRepeat = "toggleRepeat"
    private val methodToggleShuffle = "toggleShuffle"
    private val methodSetShuffle = "setShuffle"
    private val methodSetRepeatMode = "setRepeatMode"
    private val methodIsSpotifyAppActive = "isSpotifyAppActive"
    private val methodAddToLibrary = "addToLibrary"
    private val methodRemoveFromLibrary = "removeFromLibrary"
    private val methodGetCapabilities = "getCapabilities"
    private val methodGetLibraryState = "getLibraryState"
    private val methodGetImage = "getImage"

    private val paramClientId = "clientId"
    private val paramRedirectUrl = "redirectUrl"
    private val paramScope = "scope"
    private val paramSpotifyUri = "spotifyUri"
    private val paramImageUri = "imageUri"
    private val paramImageDimension = "imageDimension"
    private val paramPositionedMilliseconds = "positionedMilliseconds"
    private val paramRelativeMilliseconds = "relativeMilliseconds"
    private val paramPodcastPlaybackSpeed = "podcastPlaybackSpeed"
    private val paramTrackIndex = "trackIndex"
    private val paramRepeatMode = "repeatMode"
    private val paramShuffle = "shuffle"

    private val errorConnecting = "errorConnecting"
    private val errorDisconnecting = "errorDisconnecting"
    private val errorConnection = "errorConnection"
    private val errorAuthenticationToken = "authenticationTokenError"

    private var connStatusEventChannel: SetEvent<ConnectionStatusChannel.ConnectionEvent> = event()

    private val requestCodeAuthentication = 1337

    private var pendingOperation: PendingOperation? = null
    private var spotifyAppRemote: SpotifyAppRemote? = null
    private var spotifyPlayerApi: SpotifyPlayerApi? = null
    private var spotifyUserApi: SpotifyUserApi? = null
    private var spotifyImagesApi: SpotifyImagesApi? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.applicationContext = binding.applicationContext
        val messenger = binding.binaryMessenger

        methodChannel = MethodChannel(messenger, channelName)
        methodChannel?.setMethodCallHandler(this)

        playerContextChannel = EventChannel(messenger, playerContextSubscription)
        playerStateChannel = EventChannel(messenger, playerStateSubscription)
        capabilitiesChannel = EventChannel(messenger, capabilitiesSubscription)
        userStatusChannel = EventChannel(messenger, userStatusSubscription)
        connectionStatusChannel = EventChannel(messenger, connectionStatusSubscription)

        connectionStatusChannel?.setStreamHandler(ConnectionStatusChannel(connStatusEventChannel))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        playerContextChannel?.setStreamHandler(null)
        playerStateChannel?.setStreamHandler(null)
        capabilitiesChannel?.setStreamHandler(null)
        userStatusChannel?.setStreamHandler(null)
        connectionStatusChannel?.setStreamHandler(null)

        playerContextChannel = null
        playerStateChannel = null
        capabilitiesChannel = null
        userStatusChannel = null
        connectionStatusChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        applicationActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        applicationActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        applicationActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        applicationActivity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (spotifyAppRemote != null) {
            spotifyPlayerApi = SpotifyPlayerApi(spotifyAppRemote, result)
            spotifyUserApi = SpotifyUserApi(spotifyAppRemote, result)
            spotifyImagesApi = SpotifyImagesApi(spotifyAppRemote, result)
        }

        when (call.method) {
            methodConnectToSpotify -> connectToSpotify(call.argument(paramClientId), call.argument(paramRedirectUrl), result)
            methodGetAccessToken -> getAccessToken(call.argument(paramClientId), call.argument(paramRedirectUrl), call.argument(paramScope), result)
            methodDisconnectFromSpotify -> disconnectFromSpotify(result)
            methodGetCrossfadeState -> spotifyPlayerApi?.getCrossfadeState()
            methodGetPlayerState -> spotifyPlayerApi?.getPlayerState()
            methodPlay -> spotifyPlayerApi?.play(call.argument(paramSpotifyUri))
            methodPause -> spotifyPlayerApi?.pause()
            methodQueueTrack -> spotifyPlayerApi?.queue(call.argument(paramSpotifyUri))
            methodResume -> spotifyPlayerApi?.resume()
            methodSeekTo -> spotifyPlayerApi?.seekTo(call.argument(paramPositionedMilliseconds))
            methodSeekToRelativePosition -> spotifyPlayerApi?.seekToRelativePosition(call.argument(paramRelativeMilliseconds))
            methodSetPodcastPlaybackSpeed -> spotifyPlayerApi?.setPodcastPlaybackSpeed(call.argument(paramPodcastPlaybackSpeed))
            methodSkipNext -> spotifyPlayerApi?.skipNext()
            methodSkipPrevious -> spotifyPlayerApi?.skipPrevious()
            methodSkipToIndex -> spotifyPlayerApi?.skipToIndex(call.argument(paramSpotifyUri), call.argument(paramTrackIndex))
            methodToggleShuffle -> spotifyPlayerApi?.toggleShuffle()
            methodSetShuffle -> spotifyPlayerApi?.setShuffle(call.argument(paramShuffle))
            methodToggleRepeat -> spotifyPlayerApi?.toggleRepeat()
            methodSetRepeatMode -> spotifyPlayerApi?.setRepeatMode(call.argument(paramRepeatMode))
            methodIsSpotifyAppActive -> spotifyPlayerApi?.isSpotifyAppActive()
            methodAddToLibrary -> spotifyUserApi?.addToUserLibrary(call.argument(paramSpotifyUri))
            methodRemoveFromLibrary -> spotifyUserApi?.removeFromUserLibrary(call.argument(paramSpotifyUri))
            methodGetCapabilities -> spotifyUserApi?.getCapabilities()
            methodGetLibraryState -> spotifyUserApi?.getLibraryState(call.argument(paramSpotifyUri))
            methodGetImage -> spotifyImagesApi?.getImage(call.argument(paramImageUri), call.argument(paramImageDimension))
            else -> result.notImplemented()
        }
    }

    private fun connectToSpotify(clientId: String?, redirectUrl: String?, result: Result) {
        if (clientId.isNullOrBlank() || redirectUrl.isNullOrBlank()) {
            result.error(errorConnecting, "client id or redirectUrl are not set or have invalid format", "")
            return
        }

        val connectionParams = ConnectionParams.Builder(clientId)
            .setRedirectUri(redirectUrl)
            .showAuthView(true)
            .build()

        SpotifyAppRemote.disconnect(spotifyAppRemote)
        var initiallyConnected = false

        SpotifyAppRemote.connect(applicationContext, connectionParams, object : ConnectionListener {
            override fun onConnected(spotifyAppRemoteValue: SpotifyAppRemote) {
                spotifyAppRemote = spotifyAppRemoteValue

                playerContextChannel?.setStreamHandler(PlayerContextChannel(spotifyAppRemote!!.playerApi))
                playerStateChannel?.setStreamHandler(PlayerStateChannel(spotifyAppRemote!!.playerApi))
                capabilitiesChannel?.setStreamHandler(CapabilitiesChannel(spotifyAppRemote!!.userApi))
                userStatusChannel?.setStreamHandler(UserStatusChannel(spotifyAppRemote!!.userApi))
                initiallyConnected = true

                connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(true, "Successfully connected to Spotify.", null, null))
                result.success(true)
            }

            override fun onFailure(throwable: Throwable) {
                val errorMessage = throwable.message ?: "Unknown error"
                val errorCode = when (throwable) {
                    is SpotifyDisconnectedException -> "SpotifyDisconnectedException"
                    is SpotifyConnectionTerminatedException -> "SpotifyConnectionTerminatedException"
                    is CouldNotFindSpotifyApp -> "CouldNotFindSpotifyApp"
                    is AuthenticationFailedException -> "AuthenticationFailedException"
                    is UserNotAuthorizedException -> "UserNotAuthorizedException"
                    is UnsupportedFeatureVersionException -> "UnsupportedFeatureVersionException"
                    is OfflineModeException -> "OfflineModeException"
                    is NotLoggedInException -> "NotLoggedInException"
                    is SpotifyRemoteServiceException -> "SpotifyRemoteServiceException"
                    else -> errorConnection
                }

                if (initiallyConnected) {
                    connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(false, errorMessage, errorCode, throwable.toString()))
                } else {
                    result.error(errorCode, errorMessage, throwable.toString())
                }
            }
        })
    }

    private fun getAccessToken(clientId: String?, redirectUrl: String?, scope: String?, result: Result) {
        if (applicationActivity == null) {
            throw IllegalStateException("getAccessToken needs a foreground activity")
        }

        if (clientId.isNullOrBlank() || redirectUrl.isNullOrBlank()) {
            result.error(errorConnecting, "client id or redirectUrl are not set or have invalid format", "")
            return
        }

        val scopeArray = scope?.split(",")?.toTypedArray()
        methodConnectToSpotify.checkAndSetPendingOperation(result)

        val builder = AuthorizationRequest.Builder(clientId, AuthorizationResponse.Type.TOKEN, redirectUrl)
        builder.setScopes(scopeArray)
        val request = builder.build()

        AuthorizationClient.openLoginActivity(applicationActivity, requestCodeAuthentication, request)
    }

    private fun disconnectFromSpotify(result: Result) {
        if (spotifyAppRemote?.isConnected == true) {
            SpotifyAppRemote.disconnect(spotifyAppRemote)
            connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(false, "Successfully disconnected from Spotify.", null, null))
            result.success(true)
        } else {
            result.error(errorDisconnecting, "Could not disconnect Spotify remote", "Not connected or remote is null")
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (pendingOperation == null) return false

        return when (requestCode) {
            requestCodeAuthentication -> {
                authFlow(resultCode, data)
                true
            }
            else -> false
        }
    }

    private fun authFlow(resultCode: Int, data: Intent?) {
        val response = AuthorizationClient.getResponse(resultCode, data)
        val result = pendingOperation!!.result
        pendingOperation = null

        when (response.type) {
            AuthorizationResponse.Type.TOKEN -> result.success(response.accessToken)
            AuthorizationResponse.Type.ERROR -> result.error(errorAuthenticationToken, "Authentication failed", response.error)
            else -> result.notImplemented()
        }
    }

    private fun String.checkAndSetPendingOperation(result: Result) {
        check(pendingOperation == null) {
            "Concurrent operations detected: ${pendingOperation?.method}, $this"
        }
        pendingOperation = PendingOperation(this, result)
    }

    private class PendingOperation(val method: String, val result: Result)
}
