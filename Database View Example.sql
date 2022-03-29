--selecting all from a view created from larger dataset
--compare static population count to new vaccination count and total running vaccination count
select *
from dbo.PercentPopulationVaccinated
order by 2,3