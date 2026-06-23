package cm.digitrans.crm.repository;

import cm.digitrans.crm.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, Long> {
}
