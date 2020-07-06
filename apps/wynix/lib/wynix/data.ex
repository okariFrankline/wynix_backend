defmodule Wynix.Data do

  def practise_account do
    %{
      auth_email: "okaripauloumo@gmail.com",
      password: "okari5678",
      account_type: "practise Account",
      practise_type: "Freelance Account",
      practise_name: "Frank's Practise"
    }
  end

  def client_account do
    %{
      "auth_email" => "okari3@gmail.com",
      "password" => "okari5678",
      "account_type" => "practise Account",
      #"practise_type" => "Freelance Account"
    }
  end

  def bid do
    %{
      "deposit_amount" => 10_000,
      "asking_amount" => 70_000,
    }
  end

  def account_id, do: "429b4ec8-e1ac-4980-b6fc-bf3b3b69d9b3"

  def practise_id, do: "0d9db3e3-7373-4106-ada9-737c46fe639b"

  def order_id, do: "8f093612-5fe2-4c1f-8d61-b16c5b76c5d2"

  def new_order do
    %{
      "order_category" => "Tatoo Drawing",
      "order_type" => "Order"
    }
  end

end # end of Data
