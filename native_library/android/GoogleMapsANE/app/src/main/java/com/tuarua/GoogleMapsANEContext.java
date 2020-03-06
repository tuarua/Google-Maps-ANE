/*
 *  Copyright 2017 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.tuarua;
import com.adobe.air.AndroidActivityWrapper;
import com.tuarua.frekotlin.FreKotlinContext;
import com.tuarua.frekotlin.FreKotlinMainController;
import com.tuarua.googlemapsane.KotlinController;

public class GoogleMapsANEContext extends FreKotlinContext {
    private AndroidActivityWrapper aaw;
    private KotlinController kc;

    GoogleMapsANEContext(String name, FreKotlinMainController controller, String[] functions) {
        super(name, controller, functions);
        this.controller = controller;
        kc = (KotlinController) this.controller;
        aaw = AndroidActivityWrapper.GetAndroidActivityWrapper();
        aaw.addActivityResultListener(kc);
        aaw.addActivityStateChangeListner(kc);
    }

    @Override
    public void dispose() {
        super.dispose();
        if (aaw != null) {
            aaw.removeActivityResultListener(kc);
            aaw.removeActivityStateChangeListner(kc);
            aaw = null;
        }
        kc.dispose();
        kc = null;
    }
}
