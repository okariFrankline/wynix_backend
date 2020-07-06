defmodule Wynix.Data do

  def practise_account do
    %{
      "auth_email" => "okaripaul@gmail.com",
      "password" => "okari5678",
      "account_type" => "practise Account",
      "practise_type" => "Freelance Account",
      "practise_name" => "Frank's Practise"
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

  def account_id, do: "1c2df08f-174e-4926-9ab7-2165a0513da4"

  def practise_id, do: "0d9db3e3-7373-4106-ada9-737c46fe639b"

  def order_id, do: "1c2df08f-174e-4926-9ab7-2165a0513da4"

  def new_order do
    %{
      "order_category" => "Mobile Development",
      "order_type" => "Order"
    }
  end

end # end of Data
