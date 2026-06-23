package cm.digitrans.erp.repository;

import cm.digitrans.erp.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {
}
