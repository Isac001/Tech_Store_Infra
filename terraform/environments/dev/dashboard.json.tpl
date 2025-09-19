{
    "widgets": [
        {
            "height": 6,
            "width": 12,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", "${asg_name}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${aws_region}",
                "title": "a. EC2 Instance Health (StatusCheckFailed)",
                "period": 300
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 0,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "targetgroup/${tg_name}", "LoadBalancer", "app/${alb_name}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${aws_region}",
                "title": "b. ALB Request Count",
                "period": 300
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "${asg_name}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${aws_region}",
                "title": "c. Auto Scaling Group InServiceInstances",
                "period": 300
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 6,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${asg_name}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${aws_region}",
                "title": "d. CPU Utilization (Média do Grupo)",
                "period": 300
            }
        },
        {
            "height": 6,
            "width": 24,
            "y": 12,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${rds_db_identifier}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${aws_region}",
                "title": "e. RDS Connections",
                "period": 300
            }
        }
    ]
}