from adapters.onvif.notifications import clean_topic, parse_notifications, parse_subscription, parse_topics
from adapters.onvif.soap import parse_response

NAMESPACES = (
    'xmlns:env="http://www.w3.org/2003/05/soap-envelope" xmlns:tt="http://www.onvif.org/ver10/schema" '
    'xmlns:tev="http://www.onvif.org/ver10/events/wsdl" xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2" '
    'xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:tns1="http://www.onvif.org/ver10/topics" '
    'xmlns:wstop="http://docs.oasis-open.org/wsn/t-1"'
)

MOTION_PULL = f"""<?xml version="1.0" encoding="UTF-8"?>
<env:Envelope {NAMESPACES}><env:Body><tev:PullMessagesResponse>
<tev:CurrentTime>2026-11-19T21:44:08Z</tev:CurrentTime><tev:TerminationTime>2026-11-19T21:53:42Z</tev:TerminationTime>
<wsnt:NotificationMessage><wsnt:Topic Dialect="http://www.onvif.org/ver10/tev/topicExpression/ConcreteSet">
tns1:RuleEngine/CellMotionDetector/Motion</wsnt:Topic><wsnt:Message>
<tt:Message UtcTime="2026-11-19T21:44:08Z" PropertyOperation="Changed"><tt:Source>
<tt:SimpleItem Name="VideoSourceConfigurationToken" Value="VideoSourceToken"/>
<tt:SimpleItem Name="VideoAnalyticsConfigurationToken" Value="VideoAnalyticsToken"/>
<tt:SimpleItem Name="Rule" Value="MyMotionDetectorRule"/></tt:Source>
<tt:Data><tt:SimpleItem Name="IsMotion" Value="true"/></tt:Data></tt:Message></wsnt:Message></wsnt:NotificationMessage>
<wsnt:NotificationMessage><wsnt:Topic Dialect="http://www.onvif.org/ver10/tev/topicExpression/ConcreteSet">
tns1:VideoSource/MotionAlarm</wsnt:Topic><wsnt:Message>
<tt:Message UtcTime="2026-11-19T21:44:08Z" PropertyOperation="Changed"><tt:Source>
<tt:SimpleItem Name="Source" Value="VideoSource_1"/></tt:Source>
<tt:Data><tt:SimpleItem Name="State" Value="true"/></tt:Data></tt:Message></wsnt:Message></wsnt:NotificationMessage>
</tev:PullMessagesResponse></env:Body></env:Envelope>""".encode()

SUBSCRIPTION = f"""<env:Envelope {NAMESPACES}><env:Body><tev:CreatePullPointSubscriptionResponse>
<tev:SubscriptionReference><wsa:Address>http://192.168.1.237:8899/event_service/0</wsa:Address></tev:SubscriptionReference>
<wsnt:CurrentTime>2026-11-19T18:40:06Z</wsnt:CurrentTime><wsnt:TerminationTime>2026-11-19T18:41:06Z</wsnt:TerminationTime>
</tev:CreatePullPointSubscriptionResponse></env:Body></env:Envelope>""".encode()

PROPERTIES = f"""<env:Envelope {NAMESPACES}><env:Body><tev:GetEventPropertiesResponse>
<wstop:TopicSet><tns1:VideoSource wstop:topic="true"><tns1:MotionAlarm wstop:topic="true">
<tt:MessageDescription IsProperty="true"><tt:Source><tt:SimpleItemDescription Name="Source" Type="tt:ReferenceToken"/>
</tt:Source><tt:Data><tt:SimpleItemDescription Name="State" Type="xs:boolean"/></tt:Data></tt:MessageDescription>
</tns1:MotionAlarm></tns1:VideoSource><tns1:Device><tns1:HardwareFailure><tns1:HardDiskFull>
<tt:MessageDescription IsProperty="false"><tt:Source><tt:SimpleItemDescription Name="HardDiskNo" Type="xs:int"/>
</tt:Source></tt:MessageDescription></tns1:HardDiskFull></tns1:HardwareFailure></tns1:Device></wstop:TopicSet>
</tev:GetEventPropertiesResponse></env:Body></env:Envelope>""".encode()


def test_pull_messages_are_parsed_with_items_and_times():
    result = parse_notifications(parse_response(MOTION_PULL, 200))
    assert result.current_time.isoformat() == "2026-11-19T21:44:08+00:00"
    assert [message.topic for message in result.messages] == [
        "RuleEngine/CellMotionDetector/Motion",
        "VideoSource/MotionAlarm",
    ]
    motion = result.messages[0]
    assert motion.operation == "Changed"
    assert motion.data == {"IsMotion": "true"}
    assert motion.source["Rule"] == "MyMotionDetectorRule"
    assert motion.utc_time.isoformat() == "2026-11-19T21:44:08+00:00"
    assert motion.details()["data"] == {"IsMotion": "true"}


def test_subscription_reference_is_parsed():
    subscription = parse_subscription(parse_response(SUBSCRIPTION, 200))
    assert subscription.address == "http://192.168.1.237:8899/event_service/0"
    assert (subscription.termination_time - subscription.current_time).total_seconds() == 60


def test_topic_set_lists_paths_and_property_flag():
    topics = parse_topics(parse_response(PROPERTIES, 200))
    assert [(topic.path, topic.is_property, topic.data_items) for topic in topics] == [
        ("VideoSource/MotionAlarm", True, ("State",)),
        ("Device/HardwareFailure/HardDiskFull", False, ()),
    ]


def test_topic_prefix_is_removed():
    assert clean_topic(" tns1:VideoSource/MotionAlarm ") == "VideoSource/MotionAlarm"
    assert clean_topic("RuleEngine/CellMotionDetector/Motion") == "RuleEngine/CellMotionDetector/Motion"
