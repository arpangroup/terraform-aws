resource "aws_key_pair" "TF_KEY_PAIR" {
  key_name = "my-key-pair"
  # public_key = file("~/.ssh/id_rsa.pub") # Path to your public SSH key
  public_key = file("C:\\Users\\arpan\\.ssh\\id_rsa.pub")
}