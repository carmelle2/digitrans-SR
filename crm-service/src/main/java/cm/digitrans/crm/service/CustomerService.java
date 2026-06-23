package cm.digitrans.crm.service;

import cm.digitrans.crm.entity.Customer;
import cm.digitrans.crm.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomerService {
    private final CustomerRepository customerRepository;

    public List<Customer> findAll() {
        return customerRepository.findAll();
    }

    public Customer save(Customer customer) {
        return customerRepository.save(customer);
    }
}
