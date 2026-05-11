#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROS_DISTRO=${ROS_DISTRO:-jazzy}

set +u
source "/opt/ros/${ROS_DISTRO}/setup.bash"

WORKSPACE_SETUP=$(cd -- "${SCRIPT_DIR}/../../.." && pwd)/install/setup.bash
if [[ -f "${WORKSPACE_SETUP}" ]]; then
  source "${WORKSPACE_SETUP}"
fi
set -u

python3 - <<'PY'
import rclpy
from rclpy.node import Node
from rclpy.qos import DurabilityPolicy, HistoryPolicy, QoSProfile, ReliabilityPolicy
from std_msgs.msg import Bool


class FireAlarmStateLatch(Node):
    def __init__(self) -> None:
        super().__init__("fire_alarm_state_latch")
        qos = QoSProfile(
            history=HistoryPolicy.KEEP_LAST,
            depth=1,
            reliability=ReliabilityPolicy.RELIABLE,
            durability=DurabilityPolicy.TRANSIENT_LOCAL,
        )
        self._state = False
        self._publisher = self.create_publisher(Bool, "/fire_alarm_trigger", qos)
        self.create_subscription(Bool, "/fire_alarm_trigger", self._handle_state, qos)
        self._publish_state(self._state)
        self.get_logger().info("Latched fire alarm state: false")

    def _publish_state(self, state: bool) -> None:
        msg = Bool()
        msg.data = state
        self._publisher.publish(msg)

    def _handle_state(self, msg: Bool) -> None:
        if msg.data == self._state:
            return
        self._state = msg.data
        self._publish_state(self._state)
        self.get_logger().info("Latched fire alarm state: %s", str(self._state).lower())


def main() -> None:
    rclpy.init()
    node = FireAlarmStateLatch()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
PY