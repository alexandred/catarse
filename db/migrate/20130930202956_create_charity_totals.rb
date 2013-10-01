class CreateCharityTotals < ActiveRecord::Migration
  def up
    drop_view :charity_totals
    execute <<-SQL
      CREATE OR REPLACE VIEW charity_totals AS
        SELECT
          donations.charity_id,
          sum(donations.amount) AS donations_total,
          count(*) AS donators_total
        FROM donations
        GROUP BY donations.charity_id;
    SQL
  end
  
  def down
    execute <<-SQL
      DROP VIEW charity_totals;
    SQL
  end
end
