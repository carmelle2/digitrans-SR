package cm.digitrans.bi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DashboardSummary {
    private long totalEmployees;
    private long totalCustomers;
    private long totalOrders;
    private long totalShipments;
}
