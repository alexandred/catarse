class ModifyProjectTotals < ActiveRecord::Migration
  def up
    drop_view :project_totals
    execute <<-SQL
      CREATE OR REPLACE VIEW project_totals AS
        SELECT
          donators.project_id,
          sum(donators.amount) AS donations_total,
          count(*) AS donators_total
        FROM donators
        GROUP BY donators.project_id;
    SQL
  end
  
  def down
    execute <<-SQL
      DROP VIEW project_totals;
    SQL
  end
end
