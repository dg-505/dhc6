########## Initial Property Avoid Nil ##############

setprop("/systems/electrical/outputs/window-heat", 0.0);

########## Global Variable Definition #########
var fog_lvl = 0.0;
var frost_lvl = 0.0;
var is_warmer = 0;
var is_warmer_counter = 1;
var first_oat = 0;
var second_oat = 0;
###############################################

var rain_effects = func {


    ############ Rain drop ##########
    var airspeed = getprop("/velocities/airspeed-kt");

    var airspeed_max = 200;

    if (airspeed > airspeed_max) {airspeed = airspeed_max;}

    airspeed = math.sqrt(airspeed/airspeed_max);

    var splash_x = -0.1 - 2.0 * airspeed;
    var splash_y = 0.0;
    var splash_z = 1.0 - 1.35 * airspeed;

    setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
    setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
    setprop("/environment/aircraft-effects/splash-vector-z", splash_z);
    
    settimer(rain_effects, 0);
}


############ Fog ##########

var isWarmer = func {
    is_warmer_counter = is_warmer_counter + 1;
    if (math.fmod(is_warmer_counter, 2) == 0) {
        first_oat = getprop("/environment/temperature-degc");
    } else {
        second_oat = getprop("/environment/temperature-degc");
        is_warmer = ((second_oat - first_oat) > 0.05);
    }
    settimer(isWarmer, 1.0);
}

var fog_effects = func {
    var window_heat_on = getprop("/systems/electrical/outputs/window-heat");
    var oat = getprop("/environment/temperature-degc");
    var dew_point = getprop("/environment/dewpoint-degc");
    var relative_humidity = getprop("/environment/relative-humidity");
    
    if (is_warmer ==1 and window_heat_on < 18) {
        fog_lvl = fog_lvl + 0.01;
        if (fog_lvl > (relative_humidity / 80)) {
            fog_lvl = relative_humidity / 80;
        }
        if (fog_lvl > 1) {
            fog_lvl = 1;
        }
    } 
    if (window_heat_on >=18 ) {
        fog_lvl = fog_lvl - 0.01;
        if (fog_lvl < 0) {
            fog_lvl = 0;
        }
    }

    setprop("/environment/aircraft-effects/fog-level", fog_lvl);

    settimer(fog_effects, 0.1);
}

############ Frost ##########
var frost_effects = func {

    var window_heat_on = getprop("/systems/electrical/outputs/window-heat");
    var oat = getprop("/environment/temperature-degc");
    var dew_point = getprop("/environment/dewpoint-degc");
    var relative_humidity = getprop("/environment/relative-humidity");

    if (oat <= dew_point and oat <= 0 and window_heat_on < 18 and
        relative_humidity > 50) {
        frost_lvl = frost_lvl + 0.01;
        if (frost_lvl > (math.abs(oat) / 10)){
            frost_lvl = math.abs(oat) / 10;
        }
        if (frost_lvl > 1){
            frost_lvl = 1;
        }
    } 
    if (oat > 0 or oat > dew_point or window_heat_on >= 18) {
        frost_lvl = frost_lvl - 0.01;
        if (frost_lvl < 0) {
            frost_lvl = 0;
        }
    }

    setprop("/environment/aircraft-effects/frost-level", frost_lvl);   
    settimer(frost_effects, 0.1);
}

############## Windshield Wipers ################
var wipers = func {
    var wipers_position = getprop("/controls/electric/wipers/position-norm");
    var use_wipers = getprop("/environment/aircraft-effects/use-wipers");
    if (wipers_position <= 0) {
        setprop("/environment/aircraft-effects/use-wipers", 0);
    } else if(wipers_position>0 and wipers_position < 0.5 and use_wipers == 0) {
        setprop("/environment/aircraft-effects/use-wipers", 0);
    } else {
        setprop("/environment/aircraft-effects/use-wipers", 1);
    }
    settimer(wipers, 0.1);
}

setlistener("/sim/signals/fdm-initialized", rain_effects);
setlistener("/sim/signals/fdm-initialized", fog_effects);
setlistener("/sim/signals/fdm-initialized", isWarmer);
setlistener("/sim/signals/fdm-initialized", frost_effects);
setlistener("/sim/signals/fdm-initialized", wipers);
