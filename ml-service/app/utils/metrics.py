"""
ML Metrics
──────────
Evaluation metrics for comparing model accuracy.
"""
import numpy as np
from typing import List


def mean_absolute_error(actual: List[float], predicted: List[float]) -> float:
    """
    Mean Absolute Error (MAE).
    Lower is better. In the same units as the data.
    """
    if len(actual) != len(predicted) or not actual:
        return float('inf')
    a = np.array(actual, dtype=float)
    p = np.array(predicted, dtype=float)
    return float(np.mean(np.abs(a - p)))


def root_mean_squared_error(actual: List[float], predicted: List[float]) -> float:
    """
    Root Mean Squared Error (RMSE).
    Penalizes larger errors more than MAE.
    """
    if len(actual) != len(predicted) or not actual:
        return float('inf')
    a = np.array(actual, dtype=float)
    p = np.array(predicted, dtype=float)
    return float(np.sqrt(np.mean((a - p) ** 2)))


def mean_absolute_percentage_error(actual: List[float], predicted: List[float]) -> float:
    """
    Mean Absolute Percentage Error (MAPE).
    Expressed as a percentage. Lower is better.
    Values where actual == 0 are excluded to avoid division by zero.
    """
    if len(actual) != len(predicted) or not actual:
        return float('inf')

    errors = []
    for a, p in zip(actual, predicted):
        if a != 0:
            errors.append(abs((a - p) / a))

    if not errors:
        return 0.0
    return float(np.mean(errors) * 100)


def r_squared(actual: List[float], predicted: List[float]) -> float:
    """
    R-squared (coefficient of determination).
    1.0 = perfect, 0.0 = no better than mean, negative = worse than mean.
    """
    if len(actual) != len(predicted) or len(actual) < 2:
        return 0.0
    a = np.array(actual, dtype=float)
    p = np.array(predicted, dtype=float)
    ss_res = np.sum((a - p) ** 2)
    ss_tot = np.sum((a - np.mean(a)) ** 2)
    if ss_tot == 0:
        return 1.0
    return float(1 - (ss_res / ss_tot))


def directional_accuracy(actual: List[float], predicted: List[float]) -> float:
    """
    Directional Accuracy: percentage of times the predicted direction
    (up/down) matches the actual direction.
    """
    if len(actual) != len(predicted) or len(actual) < 2:
        return 0.0

    correct = 0
    total = 0
    for i in range(1, len(actual)):
        actual_dir = actual[i] - actual[i - 1]
        pred_dir = predicted[i] - predicted[i - 1]
        if (actual_dir >= 0 and pred_dir >= 0) or (actual_dir < 0 and pred_dir < 0):
            correct += 1
        total += 1

    return float(correct / total * 100) if total > 0 else 0.0


def evaluate_model(actual: List[float], predicted: List[float]) -> dict:
    """
    Compute all evaluation metrics for a model prediction.
    
    Returns a dict with:
      - mae, rmse, mape, r2, directional_accuracy
    """
    return {
        "mae": round(mean_absolute_error(actual, predicted), 4),
        "rmse": round(root_mean_squared_error(actual, predicted), 4),
        "mape": round(mean_absolute_percentage_error(actual, predicted), 4),
        "r2": round(r_squared(actual, predicted), 4),
        "directional_accuracy": round(directional_accuracy(actual, predicted), 2),
    }