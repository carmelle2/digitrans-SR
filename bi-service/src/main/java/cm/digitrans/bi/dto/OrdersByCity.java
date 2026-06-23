package cm.digitrans.bi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OrdersByCity {
    private Map<String, Long> ordersByCity;
}
