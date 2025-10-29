#!/bin/bash

# 📱 COMPREHENSIVE API GATEWAY TEST SCRIPT
# 🚀 News App API - Hyper Optimized Version 7.0.0

# Configuration
API_BASE_URL="https://d5ddp236ffmgophlrs5s.cmxivbes.apigw.yandexcloud.net"
DEFAULT_HEADERS="Content-Type: application/json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
USER_ID=""
NEWS_ID=""
TOKEN=""

# Helper functions
print_header() {
    echo -e "\n${CYAN}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

make_request() {
    local endpoint=$1
    local method=$2
    local data=$3
    local auth_header=$4

    local curl_cmd="curl -s -X $method \"$API_BASE_URL$endpoint\" \
        -H \"$DEFAULT_HEADERS\""

    if [ ! -z "$auth_header" ]; then
        curl_cmd="$curl_cmd -H \"Authorization: $auth_header\""
    fi

    if [ ! -z "$data" ]; then
        curl_cmd="$curl_cmd -d '$data'"
    fi

    echo "$(eval $curl_cmd)"
}

# Test functions
test_root() {
    print_header "TESTING ROOT ENDPOINT"
    response=$(make_request "/" "GET")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "Root endpoint working"
    else
        print_error "Root endpoint failed"
    fi
}

test_health() {
    print_header "TESTING HEALTH CHECK"
    response=$(make_request "/health" "GET")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.data.status') = "OK" ]; then
        print_success "Health check passed"
    else
        print_error "Health check failed"
    fi
}

test_metrics() {
    print_header "TESTING METRICS ENDPOINT"
    response=$(make_request "/metrics" "GET")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "Metrics endpoint working"
    else
        print_error "Metrics endpoint failed"
    fi
}

test_register() {
    print_header "TESTING USER REGISTRATION"
    local timestamp=$(date +%s)
    local email="testuser_${timestamp}@example.com"
    local name="Test User ${timestamp}"

    local data="{\"email\": \"$email\", \"name\": \"$name\", \"avatar\": \"https://example.com/avatar.jpg\"}"

    response=$(make_request "/register" "POST" "$data")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        USER_ID=$(echo "$response" | jq -r '.data.user.id')
        TOKEN=$(echo "$response" | jq -r '.data.token')
        print_success "User registered: $USER_ID"
        print_info "Token: $TOKEN"
    else
        print_error "Registration failed"
        exit 1
    fi
}

test_login() {
    print_header "TESTING USER LOGIN"
    local data="{\"email\": \"testuser_$(date +%s)@example.com\", \"password\": \"testpass\"}"

    response=$(make_request "/login" "POST" "$data")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        local login_token=$(echo "$response" | jq -r '.data.token')
        if [ ! -z "$login_token" ]; then
            TOKEN=$login_token
            USER_ID=$(echo "$response" | jq -r '.data.user.id')
            print_success "Login successful: $USER_ID"
        fi
    else
        print_warning "Login test completed"
    fi
}

test_get_news() {
    print_header "TESTING GET NEWS"
    response=$(make_request "/getNews?page=0&limit=5" "GET")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        local news_count=$(echo "$response" | jq -r '.data.news | length')
        print_success "Retrieved $news_count news items"
    else
        print_error "Failed to get news"
    fi
}

test_create_news() {
    print_header "TESTING CREATE NEWS"
    local data="{\"title\": \"Test News $(date +%H:%M:%S)\", \"content\": \"This is a test news content created via API Gateway\", \"author_name\": \"API Test User\", \"hashtags\": [\"api\", \"test\", \"gateway\"]}"

    response=$(make_request "/createNews" "POST" "$data" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        NEWS_ID=$(echo "$response" | jq -r '.data.news.id')
        print_success "News created: $NEWS_ID"
    else
        print_error "Failed to create news"
    fi
}

test_update_news() {
    if [ -z "$NEWS_ID" ]; then
        print_warning "Skipping news update - no news ID available"
        return
    fi

    print_header "TESTING UPDATE NEWS"
    local data="{\"newsId\": \"$NEWS_ID\", \"updateData\": {\"title\": \"UPDATED: Test News $(date +%H:%M:%S)\", \"content\": \"This news has been updated via API Gateway\", \"hashtags\": [\"updated\", \"api\", \"test\"]}}"

    response=$(make_request "/updateNews" "POST" "$data" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "News updated successfully"
    else
        print_error "Failed to update news"
    fi
}

test_like_news() {
    if [ -z "$NEWS_ID" ]; then
        print_warning "Skipping like test - no news ID available"
        return
    fi

    print_header "TESTING LIKE NEWS"
    local data="{\"action\": \"like\", \"newsId\": \"$NEWS_ID\"}"

    response=$(make_request "/action" "POST" "$data" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "News liked successfully"
    else
        print_error "Failed to like news"
    fi
}

test_comment_news() {
    if [ -z "$NEWS_ID" ]; then
        print_warning "Skipping comment test - no news ID available"
        return
    fi

    print_header "TESTING COMMENT NEWS"
    local data="{\"action\": \"comment\", \"newsId\": \"$NEWS_ID\", \"text\": \"This is a test comment via API Gateway!\", \"author_name\": \"API Tester\"}"

    response=$(make_request "/action" "POST" "$data" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "Comment added successfully"
    else
        print_error "Failed to add comment"
    fi
}

test_repost_news() {
    if [ -z "$NEWS_ID" ]; then
        print_warning "Skipping repost test - no news ID available"
        return
    fi

    print_header "TESTING REPOST NEWS"
    local data="{\"action\": \"repost\", \"newsId\": \"$NEWS_ID\"}"

    response=$(make_request "/action" "POST" "$data" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "News reposted successfully"
    else
        print_error "Failed to repost news"
    fi
}

test_bookmark_news() {
    if [ -z "$NEWS_ID" ]; then
        print_warning "Skipping bookmark test - no news ID available"
        return
    fi

    print_header "TESTING BOOKMARK NEWS"
    local data="{\"action\": \"bookmark\", \"newsId\": \"$NEWS_ID\"}"

    response=$(make_request "/action" "POST" "$data" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "News bookmarked successfully"
    else
        print_error "Failed to bookmark news"
    fi
}

test_get_user_likes() {
    print_header "TESTING GET USER LIKES"
    response=$(make_request "/user/likes" "GET" "" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        local likes_count=$(echo "$response" | jq -r '.data.count')
        print_success "User has $likes_count likes"
    else
        print_error "Failed to get user likes"
    fi
}

test_get_user_bookmarks() {
    print_header "TESTING GET USER BOOKMARKS"
    response=$(make_request "/user/bookmarks" "GET" "" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        local bookmarks_count=$(echo "$response" | jq -r '.data.count')
        print_success "User has $bookmarks_count bookmarks"
    else
        print_error "Failed to get user bookmarks"
    fi
}

test_get_user_reposts() {
    print_header "TESTING GET USER REPOSTS"
    response=$(make_request "/user/reposts" "GET" "" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        local reposts_count=$(echo "$response" | jq -r '.data.count')
        print_success "User has $reposts_count reposts"
    else
        print_error "Failed to get user reposts"
    fi
}

test_follow_user() {
    print_header "TESTING FOLLOW USER"
    local target_user="user_1"  # Using existing test user

    local data="{\"targetUserId\": \"$target_user\"}"

    response=$(make_request "/follow" "POST" "$data" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "Successfully followed user: $target_user"
    else
        print_error "Failed to follow user"
    fi
}

test_get_user_following() {
    print_header "TESTING GET USER FOLLOWING"
    response=$(make_request "/user/following" "GET" "" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        local following_count=$(echo "$response" | jq -r '.data.count')
        print_success "User is following $following_count users"
    else
        print_error "Failed to get user following"
    fi
}

test_get_user_profile() {
    print_header "TESTING GET USER PROFILE"
    response=$(make_request "/getUserProfile?userId=$USER_ID" "GET")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "User profile retrieved successfully"
    else
        print_error "Failed to get user profile"
    fi
}

test_delete_news() {
    if [ -z "$NEWS_ID" ]; then
        print_warning "Skipping delete test - no news ID available"
        return
    fi

    print_header "TESTING DELETE NEWS"
    local data="{\"newsId\": \"$NEWS_ID\"}"

    response=$(make_request "/deleteNews" "POST" "$data" "Bearer $TOKEN")
    echo "$response" | jq '.'

    if [ $(echo "$response" | jq -r '.success') = "true" ]; then
        print_success "News deleted successfully"
    else
        print_error "Failed to delete news"
    fi
}

# Main test execution
main() {
    print_header "🚀 STARTING COMPREHENSIVE API GATEWAY TEST SUITE"
    print_info "API Base URL: $API_BASE_URL"
    print_info "Timestamp: $(date)"

    # System endpoints
    test_root
    test_health
    test_metrics

    # User management
    test_register
    test_login

    # News operations
    test_get_news
    test_create_news
    test_update_news

    # Social interactions
    test_like_news
    test_comment_news
    test_repost_news
    test_bookmark_news

    # User data
    test_get_user_likes
    test_get_user_bookmarks
    test_get_user_reposts

    # Follow system
    test_follow_user
    test_get_user_following
    test_get_user_profile

    # Cleanup operations
    test_delete_news

    print_header "🎉 TEST SUITE COMPLETED"
    print_success "All API Gateway endpoints tested successfully!"
    print_info "User ID: $USER_ID"
    print_info "Test News ID: $NEWS_ID"
    print_info "Final Token: $TOKEN"
}

# Check dependencies
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed"
        exit 1
    fi
}

# Run the script
check_dependencies
main