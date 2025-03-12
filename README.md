# Godot Terminal Plugin

## 개요

Godot Terminal Plugin은 Godot Engine에서 터미널과 유사한 인터페이스를 제공하는 플러그인입니다. 사용자가 명령어를 입력하여 쉘 명령을 실행할 수 있습니다.

## 기능

- **쉘 명령어 실행**: `cd`, `ls`, `pwd` 등 모든 쉘 명령어를 실행 가능
- **경로 변경**: `cd` 명령을 사용하여 현재 작업 디렉토리 변경 가능
- **실행 결과 표시**: 명령어의 실행 결과가 UI에 지속적으로 추가됨

## 설치 방법

1. 플러그인 폴더를 Godot 프로젝트의 `addons/godot_terminal``_plugin``/` 경로에 복사합니다.
2. Godot 에디터에서 `Project` -> `Project Settings` -> `Plugins`로 이동합니다.
3. `Godot Terminal Plugin` 플러그인을 활성화합니다.
4. Godot IDE를 재부팅합니다.

## 예시 사진


## 주의 사항

- 실행 환경에 따라 일부 명령어는 지원되지 않을 수 있습니다.
- macOS에서만 테스트되었습니다. windows와 linux에서 필요하면 github으로 연락주세요. 같이 만들어보아요.

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.
