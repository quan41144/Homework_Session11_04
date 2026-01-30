create database Homework_session11_04;
-- create table
create table accounts(
	account_id serial primary key,
	customer_name varchar(100),
	balance numeric(12,2)
);
create table transactions(
	trans_id serial primary key,
	account_id int references accounts(account_id),
	amount numeric(12,2),
	trans_type varchar(20),
	created_at timestamp default now()
);
-- insert data
insert into accounts(customer_name, balance) values
('Nguyen Van A', 10000.00),
('Tran Thi B', 5000.00);
-- Viết Transaction thực hiện rút tiền
create or replace procedure sp_process(
	p_account_id int,
	p_amount numeric
)
language plpgsql
as $$
declare
	v_balance numeric;
begin
	select balance into v_balance
	from accounts where account_id = p_account_id for update;
	if v_balance is null then
		raise exception 'Tài khoản không tồn tại!';
	end if;
	if v_balance < p_amount then
		raise exception 'Số dư không đủ để thực hiện giao dịch!';
	end if;
	update accounts set balance = balance - p_amount where account_id = p_account_id;
	insert into transactions(account_id, amount, trans_type) values
	(p_account_id, p_amount, 'WITHDRAW');
exception
	when others then
		rollback;
	raise exception 'Đã xảy ra lỗi!';
end;
$$;
select * from transactions;
call sp_process(1, 2000);
-- Mô phỏng lỗi
-- Cố ý chèn lỗi trong bước ghi log (ví dụ nhập sai account_id trong bảng transactions)
call sp_process(1000, 1000000);
-- Quan sát và chứng minh rằng sau khi ROLLBACK, số dư vẫn không thay đổi