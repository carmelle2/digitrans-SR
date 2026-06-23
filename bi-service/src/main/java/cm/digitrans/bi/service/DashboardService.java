package cm.digitrans.bi.service;

import cm.digitrans.bi.dto.DashboardSummary;
import cm.digitrans.bi.dto.OrdersByCity;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {
    private final WebClient.Builder webClientBuilder;

    @Value("${erp.service.url}")
    private String erpServiceUrl;

    @Value("${crm.service.url}")
    private String crmServiceUrl;

    @Value("${supplychain.service.url}")
    private String supplychainServiceUrl;

    public DashboardSummary getSummary(String token) {
        WebClient webClient = webClientBuilder.build();

        Long employeesCount = webClient.get()
                .uri(erpServiceUrl + "/api/employees")
                .header("Authorization", "Bearer " + token)
                .retrieve()
                .bodyToFlux(Object.class)
                .collectList()
                .map(List::size)
                .map(Long::valueOf)
                .block();

        Long customersCount = webClient.get()
                .uri(crmServiceUrl + "/api/customers")
                .header("Authorization", "Bearer " + token)
                .retrieve()
                .bodyToFlux(Object.class)
                .collectList()
                .map(List::size)
                .map(Long::valueOf)
                .block();

        Long ordersCount = webClient.get()
                .uri(crmServiceUrl + "/api/orders")
                .header("Authorization", "Bearer " + token)
                .retrieve()
                .bodyToFlux(Object.class)
                .collectList()
                .map(List::size)
                .map(Long::valueOf)
                .block();

        Long shipmentsCount = webClient.get()
                .uri(supplychainServiceUrl + "/api/shipments")
                .header("Authorization", "Bearer " + token)
                .retrieve()
                .bodyToFlux(Object.class)
                .collectList()
                .map(List::size)
                .map(Long::valueOf)
                .block();

        return new DashboardSummary(
                employeesCount != null ? employeesCount : 0,
                customersCount != null ? customersCount : 0,
                ordersCount != null ? ordersCount : 0,
                shipmentsCount != null ? shipmentsCount : 0
        );
    }

    public OrdersByCity getOrdersByCity(String token) {
        WebClient webClient = webClientBuilder.build();

        List<Map<String, Object>> customers = webClient.get()
                .uri(crmServiceUrl + "/api/customers")
                .header("Authorization", "Bearer " + token)
                .retrieve()
                .bodyToFlux(new ParameterizedTypeReference<Map<String, Object>>() {})
                .collectList()
                .block();

        List<Map<String, Object>> orders = webClient.get()
                .uri(crmServiceUrl + "/api/orders")
                .header("Authorization", "Bearer " + token)
                .retrieve()
                .bodyToFlux(new ParameterizedTypeReference<Map<String, Object>>() {})
                .collectList()
                .block();

        Map<Long, String> customerCityMap = new HashMap<>();
        if (customers != null) {
            for (Map<String, Object> customer : customers) {
                Long id = ((Number) customer.get("id")).longValue();
                String ville = (String) customer.get("ville");
                customerCityMap.put(id, ville);
            }
        }

        Map<String, Long> ordersByCityMap = new HashMap<>();
        if (orders != null) {
            for (Map<String, Object> order : orders) {
                Long customerId = ((Number) order.get("customerId")).longValue();
                String ville = customerCityMap.getOrDefault(customerId, "Unknown");
                ordersByCityMap.put(ville, ordersByCityMap.getOrDefault(ville, 0L) + 1);
            }
        }

        return new OrdersByCity(ordersByCityMap);
    }
}
