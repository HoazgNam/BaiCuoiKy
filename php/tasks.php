<?php
error_reporting(0);
ini_set('display_errors', 0);
ob_clean();
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

$method = $_SERVER['REQUEST_METHOD'];
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tennaoccxdc";

// Kết nối MySQL
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
  http_response_code(500);
  die(json_encode(["error" => "Kết nối thất bại: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);
$id = $_GET['id'] ?? null;
$methodOverride = $_GET['_method'] ?? null;

switch ($method) {
  case 'GET':
    $sql = "SELECT * FROM tasks ORDER BY createdAt DESC";
    $result = $conn->query($sql);
    $tasks = [];
    while ($row = $result->fetch_assoc()) {
      $row['id'] = strval($row['id']); // ép về string
      $tasks[] = $row;
    }
    echo json_encode($tasks);
    break;

  case 'POST':
    if ($methodOverride === 'PUT') {
      if (!$id || !$data) {
        http_response_code(400);
        echo json_encode(["error" => "Thiếu ID hoặc dữ liệu"]);
        exit;
      }

      $attachments = [];
      if (isset($data['attachments'])) {
        if (is_string($data['attachments'])) {
          $decoded = json_decode($data['attachments'], true);
          if (is_array($decoded)) $attachments = $decoded;
        } elseif (is_array($data['attachments'])) {
          $attachments = $data['attachments'];
        }
      }
      $attachments = json_encode($attachments);

      $assignedTo = isset($data['assignedTo']) && $data['assignedTo'] !== '' ? $data['assignedTo'] : null;

      $stmt = $conn->prepare("UPDATE tasks SET 
        title=?, description=?, status=?, priority=?, 
        dueDate=?, updatedAt=?, createdBy=?, assignedTo=?, 
        category=?, attachments=?, completed=?
        WHERE id=?");

      $stmt->bind_param(
        "sssisssssssi",
        $data['title'],
        $data['description'],
        $data['status'],
        $data['priority'],
        $data['dueDate'],
        $data['updatedAt'],
        $data['createdBy'],
        $assignedTo,
        $data['category'],
        $attachments,
        $data['completed'],
        $id
      );

      if ($stmt->execute()) {
        echo json_encode(["message" => "Cập nhật thành công"]);
      } else {
        http_response_code(500);
        echo json_encode(["error" => "Cập nhật thất bại"]);
      }

    } elseif ($methodOverride === 'DELETE') {
      if (!$id) {
        http_response_code(400);
        echo json_encode(["error" => "Thiếu ID"]);
        exit;
      }

      $stmt = $conn->prepare("DELETE FROM tasks WHERE id=?");
      $stmt->bind_param("s", $id);
      if ($stmt->execute()) {
        echo json_encode(["message" => "Xoá thành công"]);
      } else {
        http_response_code(500);
        echo json_encode(["error" => "Xoá thất bại"]);
      }

    } else {
      if (!$data || !isset($data['id']) || !isset($data['title']) || !isset($data['createdAt'])) {
        http_response_code(400);
        echo json_encode(["error" => "Thiếu dữ liệu bắt buộc"]);
        exit;
      }

      $taskId = $data['id']; // DÙNG ID từ Flutter

      $attachments = [];
      if (isset($data['attachments'])) {
        if (is_string($data['attachments'])) {
          $decoded = json_decode($data['attachments'], true);
          if (is_array($decoded)) $attachments = $decoded;
        } elseif (is_array($data['attachments'])) {
          $attachments = $data['attachments'];
        }
      }
      $attachments = json_encode($attachments);

      $assignedTo = isset($data['assignedTo']) && $data['assignedTo'] !== '' ? $data['assignedTo'] : null;

      $stmt = $conn->prepare("INSERT INTO tasks 
        (id, title, description, status, priority, dueDate, createdAt, updatedAt, createdBy, assignedTo, category, attachments, completed)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

      $stmt->bind_param(
        "ssssisssssssi",
        $taskId,
        $data['title'],
        $data['description'],
        $data['status'],
        $data['priority'],
        $data['dueDate'],
        $data['createdAt'],
        $data['updatedAt'],
        $data['createdBy'],
        $assignedTo,
        $data['category'],
        $attachments,
        $data['completed']
      );

      if ($stmt->execute()) {
        echo json_encode(["message" => "Tạo task thành công", "id" => strval($taskId)]);
      } else {
        http_response_code(500);
        echo json_encode(["error" => "Tạo task thất bại"]);
      }
    }
    break;

  default:
    http_response_code(405);
    echo json_encode(["error" => "Phương thức không hỗ trợ"]);
}

$conn->close();
?>
