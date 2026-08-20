-- Seed demo data for the home named "Testing".
-- Run in Supabase SQL Editor (bypasses RLS). Safe to re-run: replaces
-- electricity / water / expenses / incomes for that home only.
-- Looks up tracking_mode, kwh_rate, m3_rate, and owner from existing rows.
-- Does not insert bill photos.

do $$
declare
  v_home public.homes%rowtype;
  v_owner uuid;
  v_month date;
  v_i int;
  v_prev_kwh numeric := 1200;
  v_new_kwh numeric;
  v_cons_kwh numeric;
  v_prev_m3 numeric := 48;
  v_new_m3 numeric;
  v_cons_m3 numeric;
  v_cat_food uuid;
  v_cat_loan uuid;
  v_cat_health uuid;
  v_cat_tuition uuid;
  v_cat_other uuid;
begin
  select * into strict v_home
  from public.homes
  where name = 'Testing';

  select user_id into strict v_owner
  from public.home_members
  where home_id = v_home.id and role = 'owner';

  select id into strict v_cat_food
  from public.expense_categories
  where home_id = v_home.id and name = 'Ăn uống/Chợ';
  select id into strict v_cat_loan
  from public.expense_categories
  where home_id = v_home.id and name = 'Vay/Trả góp';
  select id into strict v_cat_health
  from public.expense_categories
  where home_id = v_home.id and name = 'Bảo hiểm/Y tế';
  select id into strict v_cat_tuition
  from public.expense_categories
  where home_id = v_home.id and name = 'Học phí con';
  select id into strict v_cat_other
  from public.expense_categories
  where home_id = v_home.id and name = 'Khác';

  delete from public.expenses where home_id = v_home.id;
  delete from public.incomes where home_id = v_home.id;
  delete from public.electricity_periods where home_id = v_home.id;
  delete from public.water_periods where home_id = v_home.id;

  raise notice 'Seeding home % (%) mode=% kwh_rate=% m3_rate=% owner=%',
    v_home.name, v_home.id, v_home.tracking_mode, v_home.kwh_rate, v_home.m3_rate, v_owner;

  for v_i in 0..5 loop
    v_month := (date_trunc('month', current_date) - make_interval(months => 5 - v_i))::date;

    if v_home.tracking_mode = 'meter' then
      v_cons_kwh := 160 + v_i * 12;
      v_new_kwh := v_prev_kwh + v_cons_kwh;
      insert into public.electricity_periods (
        home_id, period_month, previous_kwh, new_kwh, consumption_kwh,
        amount_vnd, note, recorded_at, is_paid
      ) values (
        v_home.id,
        v_month,
        v_prev_kwh,
        v_new_kwh,
        v_cons_kwh,
        round(v_cons_kwh * v_home.kwh_rate),
        'seed',
        v_month + interval '12 days',
        v_i < 5
      );
      v_prev_kwh := v_new_kwh;

      v_cons_m3 := 9 + v_i;
      v_new_m3 := v_prev_m3 + v_cons_m3;
      insert into public.water_periods (
        home_id, period_month, previous_m3, new_m3, consumption_m3,
        amount_vnd, note, recorded_at, is_paid
      ) values (
        v_home.id,
        v_month,
        v_prev_m3,
        v_new_m3,
        v_cons_m3,
        round(v_cons_m3 * v_home.m3_rate),
        'seed',
        v_month + interval '13 days',
        v_i < 5
      );
      v_prev_m3 := v_new_m3;
    else
      insert into public.electricity_periods (
        home_id, period_month, amount_vnd, note, recorded_at, is_paid
      ) values (
        v_home.id,
        v_month,
        850000 + v_i * 40000,
        'seed',
        v_month + interval '12 days',
        v_i < 5
      );
      insert into public.water_periods (
        home_id, period_month, amount_vnd, note, recorded_at, is_paid
      ) values (
        v_home.id,
        v_month,
        180000 + v_i * 15000,
        'seed',
        v_month + interval '13 days',
        v_i < 5
      );
    end if;

    insert into public.incomes (
      home_id, user_id, amount_vnd, income_month, source, note
    ) values (
      v_home.id,
      v_owner,
      15000000,
      v_month,
      'Lương',
      'seed'
    );

    insert into public.expenses (
      home_id, category_id, paid_by, amount_vnd, expense_date, note
    ) values
      (
        v_home.id, v_cat_food, v_owner,
        2200000 + v_i * 80000,
        v_month + 4, 'seed chợ'
      ),
      (
        v_home.id, v_cat_loan, v_owner,
        3500000,
        v_month + 8, 'seed trả góp'
      ),
      (
        v_home.id, v_cat_health, v_owner,
        450000,
        v_month + 11, 'seed y tế'
      ),
      (
        v_home.id, v_cat_other, v_owner,
        180000 + v_i * 20000,
        v_month + 18, 'seed khác'
      );

    if v_i in (0, 3) then
      insert into public.expenses (
        home_id, category_id, paid_by, amount_vnd, expense_date, note
      ) values (
        v_home.id, v_cat_tuition, v_owner,
        2500000,
        v_month + 15, 'seed học phí'
      );
    end if;
  end loop;
end $$;

select
  h.name,
  h.tracking_mode,
  (select count(*) from public.electricity_periods e where e.home_id = h.id) as elec,
  (select count(*) from public.water_periods w where w.home_id = h.id) as water,
  (select count(*) from public.expenses x where x.home_id = h.id) as expenses,
  (select count(*) from public.incomes i where i.home_id = h.id) as incomes
from public.homes h
where h.name = 'Testing';
