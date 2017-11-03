static func play_animation(animator, key):
    if animator.get_current_animation() != key:
        animator.play(key)