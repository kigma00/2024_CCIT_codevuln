import requests
from bs4 import BeautifulSoup, Comment
from urllib.parse import urljoin, urlparse

def save_input_tags_to_html(url, max_depth=2):
    print("now parsing...")
    visited_urls = set()
    content = []

    ## parse html info with crawling algorithm
    def dfs_crawl(current_url, depth):
        nonlocal content, visited_urls

        if current_url in visited_urls or '#' in current_url or depth > max_depth:
            return

        try:
            # URL에서 HTML 가져오기
            response = requests.get(current_url)
            # 에러 예외 처리
            response.raise_for_status()

            # HTML 파싱
            soup = BeautifulSoup(response.text, 'html.parser')

            # <input> 태그 찾기
            input_tags = soup.find_all('input')

            # <form> 태그 찾기
            form_tags = soup.find_all('form')

            # 보안 관련 헤더 불러오기
            security_headers = get_security_headers(current_url)

            # 페이지 정보 기록
            page_info = {
                'url': current_url,
                'input_tags': input_tags,
                'forms': [],
                'comments': [],
                'security_headers': security_headers
            }

            # 각 form 태그에 대해 GET 및 POST 요청을 보내고 결과를 기록
            for form_tag in form_tags:
                form_info = {
                    'method': form_tag.get('method', 'GET'),
                    'action': form_tag.get('action', ''),
                    'response': {}
                }

                # GET 요청 보내기
                get_response = requests.get(urljoin(current_url, form_info['action']))
                form_info['response']['GET'] = {
                    'status_code': get_response.status_code,
                    'content': get_response.text
                }

                # POST 요청 보내기
                post_data = {'submit': 'a'}  # 임의의 밸류 'a'
                post_response = requests.post(urljoin(current_url, form_info['action']), data=post_data)
                form_info['response']['POST'] = {
                    'status_code': post_response.status_code,
                    'content': post_response.text
                }

                page_info['forms'].append(form_info)

            # HTML 주석 찾기
            html_comments = soup.find_all(string=lambda text: isinstance(text, Comment))
            page_info['comments'] = html_comments

            content.append(page_info)

            # 현재 URL을 방문한 것으로 표시
            visited_urls.add(current_url)

            # 현재 페이지에서 모든 링크 추출
            links = soup.find_all('a', href=True)
            for link in links:
                next_url = urljoin(current_url, link['href'])

                # 절대 URL로 변환
                next_url = urlparse(next_url)._replace(query='').geturl()

                # 다음 페이지로 이동 (재귀 호출)
                dfs_crawl(next_url, depth + 1)

        except requests.exceptions.RequestException as e:
            print(f"Error fetching the URL: {e}")

    # 최초의 URL에서 시작
    dfs_crawl(url, 0)

    return content

# 보안 관련 헤더 파싱
def get_security_headers(url):
    try:
        response = requests.get(url)
        response.raise_for_status()
        security_headers = {
            "Content-Security-Policy": response.headers.get("Content-Security-Policy", "❌"),
            "X-Content-Type-Options": response.headers.get("X-Content-Type-Options", "❌"),
            "X-Frame-Options": response.headers.get("X-Frame-Options", "❌"),
            "X-XSS-Protection": response.headers.get("X-XSS-Protection", "❌"),
            "Strict-Transport-Security": response.headers.get("Strict-Transport-Security", "❌"),
            "Referrer-Policy": response.headers.get("Referrer-Policy", "❌"),
            "Permissions-Policy": response.headers.get("Permissions-Policy", "❌"),
        }
        return security_headers
    except requests.exceptions.RequestException as e:
        print(f"Error fetching the URL: {e}")
        return None