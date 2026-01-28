package com.dddverify;

import javax.annotation.Nullable;
import com.facebook.react.bridge.WritableMap;

public interface DverifyImplSendJSEvent {
    void send(String name, @Nullable WritableMap body);
}
