from machine import Pin
from neopixel import NeoPixel
import time
import network

#########################################################
# constants
#########################################################

MIN_LOOP_ITERATION = 0
MAX_LOOP_ITERATION = 1000

CONTROL_MODE_ACTIVATION_DELAY_MS = 5000

TOUCH_SENSOR_MAX_COUNTER = 120
TOUCH_SENSOR_THRESHOLD = 15
TOUCH_MAX_SATURATION = 200

PIN_NEOPIXEL = Pin(15, Pin.OUT)
PIN_VIBROMOTOR = Pin(14, Pin.OUT)
PIN_ANTENNA_TX = Pin(16, Pin.OUT)
PIN_ANTENNA_RX = Pin(17, Pin.IN)
PIN_CONTROL_BUTTON = Pin(13, Pin.IN)

#########################################################
# data model
#########################################################


class Lights:
    enabled = False
    neopixel = NeoPixel(PIN_NEOPIXEL, 2)
    current_color = (0, 0, 0)
    func = lambda s: (0, 0, 0)

class VibroMotor:
    enabled = False
    func = lambda s: False

class TouchSensor:
    enabled = False
    measuring_in_progress = False
    current_counter = 0
    counter = 0
    saturation = 0

class ControlButton:
    pressed_at = -1

class Mode:
    regular = 1 # wait for event
    touch = 2 # touch routine - from touch till emit the event
    shine_after_touch = 3 # event was emitted, keep shining for some time
    announce = 4 # the event received from the server and presented
    control = 5 # control mode (e.g. local web server for settings adjustment)

class Iteration:
    i = 0
    consumers = 0

    def get(self):
        if self.consumers > 0:
            return self.i
        else:
            return 0

    def proceed(self):
        if self.consumers > 0:
            self.i = self.i + 1
        else:
            self.i = 0

    def start_iterating(self):
        self.consumers = self.consumers + 1
    
    def stop_iterating(self):
        if self.consumers > 0:
            self.consumers = self.consumers - 1
        else:
            self.i = 0

class Settings:
    local_color = (0, 97, 0)
    wifi_ssid = ""
    wifi_password = ""

class ServerAnnouncement:
    color = (0, 0, 0)

class ServerResponse:
    annoucement: ServerAnnouncement
    settings: Settings

class Network:
    enabled = False
    wlan = None
    connection_in_progress = False
    mode = 0

class State:
    lights = Lights()
    vibro_motor = VibroMotor()
    touch_sensor = TouchSensor()
    control_button = ControlButton()
    mode = Mode.regular
    iteration = Iteration()
    current_settings = Settings()
    network = Network()


#########################################################
# lights functions
#########################################################


# light up towards saturation
def lights_touch(s: State) -> tuple:
    # saturation 0.0..1.0
    saturation_k = s.touch_sensor.saturation / TOUCH_MAX_SATURATION
    color = s.current_settings.local_color
    max_reduce_delta = min(color[0], color[1], color[2])
    max_increase_delta = 255 - max(color[0], color[1], color[2])
    overal_range = max_reduce_delta + max_increase_delta
    target_position = overal_range * saturation_k
    delta = 0
    if target_position <= max_reduce_delta:
        delta = -(max_reduce_delta - target_position)
    else:
        delta = target_position - max_reduce_delta
    return (round(color[0] + delta), round(color[1] + delta), round(color[2] + delta))


def __signum(x):
    if x == 0:
        return 0
    else:
        return x / abs(x)


def __follow_color_component(begin, target, i):
    d = __signum(begin - target)
    val = min(max(begin + -d * i, 0), 255)
    if (d > 0 and val < target) or (d < 0 and val > target):
        val = target
    return round(val)

# slowly return back to the base color, keep it for some time and go slowly into darkness
def lights_after_touch(s: State, begin_iteration, begin_color) -> tuple:
    i = s.iteration.get() - begin_iteration
    base_color = s.current_settings.local_color

    if i > 500:
        return (0, 0, 0)

    begin_color = s.lights.current_color
    return (
        __follow_color_component(begin_color[0], base_color[0], i),
        __follow_color_component(begin_color[1], base_color[1], i),
        __follow_color_component(begin_color[2], base_color[2], i),
    )

#########################################################
# vibro motor functions
#########################################################
def vibro_motor_click(s: State, begin_iteration) -> bool:
    i = s.iteration.get() - begin_iteration
    return i < 2

#########################################################
# hardware methods
#########################################################

## control button
def control_button(s: State):
    value = PIN_CONTROL_BUTTON.value()
    if value == 0:
        s.control_button.pressed_at = -1
    else:
        if s.control_button.pressed_at < 0:
            s.control_button.pressed_at = time.ticks_ms()
        else:
            if time.ticks_ms() - s.control_button.pressed_at > CONTROL_MODE_ACTIVATION_DELAY_MS:
                s.control_button.pressed_at = -1
                s.mode = Mode.control


## touch sensor
def touch_sensor(s: State):
    sensor = s.touch_sensor
    if not sensor.enabled:
        PIN_ANTENNA_TX.off()
        sensor.current_counter = 0
        return
    PIN_ANTENNA_TX.on()
    sensor.current_counter = 0
    while PIN_ANTENNA_RX.value() < 1 and sensor.current_counter < TOUCH_SENSOR_MAX_COUNTER:
        sensor.current_counter = sensor.current_counter + 1
    PIN_ANTENNA_TX.off()
    sensor.counter = sensor.current_counter

    
    #if sensor.measuring_in_progress == True:
    #    val = PIN_ANTENNA_RX.value()
    #    #print(f"val {val}")
    #    if val < 1 and sensor.current_counter < TOUCH_SENSOR_MAX_COUNTER:
    #        sensor.current_counter = sensor.current_counter + 1
    #    else:
    #        PIN_ANTENNA_TX.off()
    #        sensor.measuring_in_progress = False
    #        sensor.counter = sensor.current_counter
    #else:
    #    PIN_ANTENNA_TX.on()
    #    sensor.current_counter = 0
    #    sensor.measuring_in_progress = True

## lights
def lights(s: State):
    if not s.lights.enabled:
        s.lights.neopixel.fill((0, 0, 0))
        s.lights.neopixel.write()
        return
    color = s.lights.func(s)
    s.lights.neopixel.fill(color)
    s.lights.neopixel.write()
    s.lights.current_color = color


## vibro motor
def vibro_motor(s: State):
    if not s.vibro_motor.enabled:
        PIN_VIBROMOTOR.off()
        return
    if s.vibro_motor.func(s):
        PIN_VIBROMOTOR.on()
    else:
        PIN_VIBROMOTOR.off()


#########################################################
# WiFi
#########################################################
def wifi_setup_client(s: State):
    if not s.network.enabled:
        if not s.network.wlan is None:
            if s.network.wlan.active():
                if s.network.wlan.isconnected():
                    s.network.wlan.disconnect()
                s.network.wlan.active(False)
                s.network.wlan = None
        return
    
    #todo check if wifi credentials are known, e.g. if not, no need to proceed
    #todo check if wlan mode is client, e.g. reconnect if not?

    if s.network.wlan is None:
        s.network.wlan = network.WLAN(network.STA_IF)
        s.network.mode = network.STA_IF

    if not s.network.wlan.active():
        s.network.wlan.active(True)

    if not s.network.wlan.isconnected() and not s.network.connection_in_progress:
        s.network.wlan.connect(
            s.current_settings.wifi_ssid,
            s.current_settings.wifi_password
        )
        s.network.connection_in_progress = True

    # todo retry logic, e.g. connection is in progress to long
    #print('network config:', wlan.ifconfig())
    #return

# import network

# wlan = network.WLAN(network.STA_IF) # create station interface
# wlan.active(True)       # activate the interface
# wlan.scan()             # scan for access points
# wlan.isconnected()      # check if the station is connected to an AP
# wlan.connect('ssid', 'key') # connect to an AP
# wlan.config('mac')      # get the interface's MAC address
# wlan.ifconfig()         # get the interface's IP/netmask/gw/DNS addresses

# ap = network.WLAN(network.AP_IF) # create access-point interface
# ap.active(True)         # activate the interface
# ap.config(ssid='ESP-AP') # set the SSID of the access point

def wifi_setup_point(s: State):
    if not s.network.enabled:
        if not s.network.wlan is None:
            if s.network.wlan.active():
                if s.network.wlan.isconnected():
                    s.network.wlan.disconnect()
                s.network.wlan.active(False)
                s.network.wlan = None
        return

    #todo check if wlan mode is client, e.g. reconnect if not?

    if s.network.wlan is None:
        s.network.wlan = network.WLAN(network.AP_IF)
        s.network.mode = network.AP_IF

    if not s.network.wlan.active():
        s.network.wlan.active(True)
        s.network.wlan.config(ssid = "egg") #todo ssid constant
    

#########################################################
# data and server
#########################################################
def read_local_settings() -> Settings:
    return Settings()

def save_local_settings(settings):
    return

def ask_server() -> ServerResponse:
    return ServerResponse()

def emit_touch_event():
    return

#########################################################
# core
#########################################################
def controller(s: State):
    if s.mode == Mode.regular or s.mode == Mode.touch:
        s.touch_sensor.enabled = True
    else:
        s.touch_sensor.enabled = False

    if s.touch_sensor.enabled:
        if s.touch_sensor.counter > TOUCH_SENSOR_THRESHOLD:
            if s.touch_sensor.saturation < TOUCH_MAX_SATURATION:
                s.touch_sensor.saturation = s.touch_sensor.saturation + 10
        else:
            if s.touch_sensor.saturation > 0:
                s.touch_sensor.saturation = s.touch_sensor.saturation - 1
    
    if s.mode == Mode.regular and s.touch_sensor.saturation > 0:
        s.mode = Mode.touch
        s.lights.enabled = True
        s.lights.func = lambda st: lights_touch(st)
        s.iteration.start_iterating()

    if s.mode == Mode.touch and s.touch_sensor.saturation == TOUCH_MAX_SATURATION:
        #print(">>>> mode touch -> shine")
        emit_touch_event()
        s.touch_sensor.saturation = 0
        s.iteration.stop_iterating()
        s.iteration.start_iterating()
        current_iteration = s.iteration.get()
        s.mode = Mode.shine_after_touch
        s.lights.enabled = True
        s.lights.func = lambda st: lights_after_touch(st, current_iteration, s.lights.current_color)
        s.vibro_motor.enabled = True
        s.vibro_motor.func = lambda st: vibro_motor_click(st, current_iteration)


    if s.mode == Mode.shine_after_touch and s.lights.func(s) == (0, 0, 0):
        #print(">>>> shine -> regular")
        s.mode = Mode.regular
        s.lights.enabled = False
        s.vibro_motor.enabled = False
        s.iteration.stop_iterating()

    if s.mode == Mode.touch and s.touch_sensor.saturation == 0:
        s.mode = Mode.regular
        s.lights.enabled = False
        s.lights.func = lambda st: (0, 0, 0)
        s.iteration.stop_iterating()

    if s.mode == Mode.regular:
        response = ask_server()

    s.iteration.proceed()
    #sat = s.touch_sensor.saturation
    #cou = s.touch_sensor.current_counter
    #print(f"sat {sat} current_cou {cou} cou {s.touch_sensor.counter}")

def loop(s: State):
    # input
    control_button(s)
    touch_sensor(s)

    # process
    controller(s)

    # reaction
    lights(s)
    vibro_motor(s)


def start():
    current_state = State()
    current_state.current_settings = read_local_settings()
    while True:
        loop(current_state)
        time.sleep_ms(10)

if __name__ == "__main__":
    start()
