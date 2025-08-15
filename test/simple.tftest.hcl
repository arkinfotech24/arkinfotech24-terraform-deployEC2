run "plan_simple" {
  command = plan
  module  = "./fixtures/simple"

  assert {
    condition     = length(resources.aws_instance) == 1
    error_message = "Expected exactly one aws_instance."
  }

  assert {
    condition     = output.instance_id != null
    error_message = "instance_id output must exist."
  }
}
