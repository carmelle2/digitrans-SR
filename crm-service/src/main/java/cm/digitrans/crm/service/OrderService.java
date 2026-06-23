package cm.digitrans.crm.service;

import cm.digitrans.crm.entity.Order;
import cm.digitrans.crm.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;

    public List<Order> findAll() {
        return orderRepository.findAll();
    }

    public List<Order> findByCustomerId(Long customerId) {
        return orderRepository.findByCustomerId(customerId);
    }

    public Order save(Order order) {
        return orderRepository.save(order);
    }
}
