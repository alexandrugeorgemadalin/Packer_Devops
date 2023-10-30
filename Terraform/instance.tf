resource "aws_instance" "instance" {
    count = var.instance_count
    ami = "${data.aws_ami.application-ami.id}"
    instance_type = "${var.instance_type}"
    security_groups = ["${aws_security_group.sg.name}"]
}