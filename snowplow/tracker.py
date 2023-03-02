from snowplow_tracker import Emitter, Tracker, Subject

e = Emitter("127.0.0.1", port=31052, protocol="http")
default_subject = Subject().set_platform("srv")
t = Tracker([e]) 
# at this point the Tracker's subject is the default_subject. 
# The default_subject will be used in cases where an event_subject is not provided

for i in range(100):
    # specifying event_subject - supported by all track methods
    evSubject = Subject().set_platform("srv").set_user_id("tester")
    t.track_page_view("www.example.com", event_subject=evSubject)

    t.track_add_to_cart("sku1234", 1, event_subject=Subject().set_user_id("Bob"))