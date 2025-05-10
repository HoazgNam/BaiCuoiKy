<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

$method = $_SERVER['REQUEST_METHOD'];
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tennaoccxdc"; // tên mới

// Kết nối CSDL
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
  http_response_code(500);
  die(json_encode(["error" => "Kết nối thất bại: " . $conn->connect_error]));
}

// Nhận JSON body
$data = json_decode(file_get_contents("php://input"), true);

// Lấy id từ URL nếu có
$id = $_GET['id'] ?? null;
$methodOverride = $_GET['_method'] ?? null;

switch ($method) {
  case 'GET':
    $sql = "SELECT * FROM users";
    $result = $conn->query($sql);
    $users = [];

    while ($row = $result->fetch_assoc()) {
      $users[] = $row;
    }

    echo json_encode($users);
    break;

  case 'POST':
    // Xử lý PUT (cập nhật)
    if ($methodOverride === 'PUT') {
      if (!$id || !$data) {
        http_response_code(400);
        echo json_encode(["error" => "Thiếu ID hoặc dữ liệu"]);
        exit;
      }

      $stmt = $conn->prepare("UPDATE users SET username=?, email=?, password=?, createdAt=?, lastActive=?, role=? WHERE id=?");
      $stmt->bind_param(
        "ssssssi",
        $data['username'],
        $data['email'],
        $data['password'],
        $data['createdAt'],
        $data['lastActive'],
        $data['role'],
        $id
      );

      if ($stmt->execute()) {
        echo json_encode(["message" => "Cập nhật thành công"]);
      } else {
        http_response_code(500);
        echo json_encode(["error" => "Cập nhật thất bại"]);
      }

    }
    // Xử lý DELETE (xóa)
    elseif ($methodOverride === 'DELETE') {
      if (!$id) {
        http_response_code(400);
        echo json_encode(["error" => "Thiếu ID"]);
        exit;
      }

      $stmt = $conn->prepare("DELETE FROM users WHERE id=?");
      $stmt->bind_param("i", $id);
      if ($stmt->execute()) {
        echo json_encode(["message" => "Xoá thành công"]);
      } else {
        http_response_code(500);
        echo json_encode(["error" => "Xoá thất bại"]);
      }

    }
    // Xử lý POST (đăng ký mới)
    else {
      if (!$data) {
        http_response_code(400);
        echo json_encode(["error" => "Không có dữ liệu gửi lên"]);
        exit;
      }

      $stmt = $conn->prepare("INSERT INTO users (id, username, email, password, createdAt, lastActive, role) VALUES (?, ?, ?, ?, ?, ?, ?)");
      $stmt->bind_param(
        "issssss",
        $data['id'],
        $data['username'],
        $data['email'],
        $data['password'],
        $data['createdAt'],
        $data['lastActive'],
        $data['role']
      );

      if ($stmt->execute()) {
        echo json_encode($data); // trả về dữ liệu vừa lưu
      } else {
        http_response_code(500);
        echo json_encode(["error" => "Tạo tài khoản thất bại"]);
      }
    }
    break;

  default:
    http_response_code(405);
    echo json_encode(["error" => "Phương thức không hỗ trợ"]);
}

$conn->close();
?>
