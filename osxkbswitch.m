#include <stdio.h>
#include <emacs-module.h>
#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

int plugin_is_GPL_compatible;


static emacs_value
Fkeyboard_layout (emacs_env * env, ptrdiff_t nargs, emacs_value args[],
                  void *data)
{
  TISInputSourceRef current_source = TISCopyCurrentKeyboardInputSource();
  NSString *s = (__bridge NSString *)(TISGetInputSourceProperty(current_source, kTISPropertyInputSourceID));
  return env->make_string (env, [s UTF8String], s.length);
}

static emacs_value
Fset_keyboard_layout (emacs_env * env, ptrdiff_t nargs, emacs_value args[],
                      void *data)
{
  ptrdiff_t size = 0;
  env->copy_string_contents(env, args[0], nil, &size);
  char *arg = malloc(size);
  env->copy_string_contents(env, args[0], arg, &size);
  NSString* layout_name = [NSString stringWithUTF8String: arg];
  free(arg);

  NSArray* sources = CFBridgingRelease(TISCreateInputSourceList((__bridge CFDictionaryRef)@{ (__bridge NSString*)kTISPropertyInputSourceID :  layout_name}, FALSE));
  TISInputSourceRef source = (__bridge TISInputSourceRef)sources[0];
  OSStatus status = TISSelectInputSource(source);
  if (status != noErr) {
     return env->make_string (env, "Unknown layout", 14);
  }

  return nil;
}

extern
int emacs_module_init (struct emacs_runtime *ert)

{
  emacs_env *env = ert->get_environment (ert);

  emacs_value Qfeat = env->intern (env, "osxkbswitch");
  emacs_value Qprovide = env->intern (env, "provide");

  emacs_value pargs[] = { Qfeat };
  env->funcall (env, Qprovide, 1, pargs);

  emacs_value Qfset = env->intern (env, "fset");

  // keyboard-layout
  emacs_value keyboard_layout_fn = env->make_function (env, 0, 0, Fkeyboard_layout,
                                                       "Returns keyboard layout", NULL);
  emacs_value keyboard_layout_Qsym = env->intern (env, "keyboard-layout");
  emacs_value keyboard_layout_fargs[] = { keyboard_layout_Qsym, keyboard_layout_fn };
  env->funcall(env, Qfset, 2, keyboard_layout_fargs);

  // set-keyboard-layout
  emacs_value set_keyboard_layout_fn = env->make_function (env, 1, 1, Fset_keyboard_layout,
                                                           "Sets keyboard layout", NULL);
  emacs_value set_keyboard_layout_Qsym = env->intern (env, "set-keyboard-layout");
  emacs_value set_keyboard_layout_fargs[] = { set_keyboard_layout_Qsym, set_keyboard_layout_fn };
  env->funcall(env, Qfset, 2, set_keyboard_layout_fargs);

  return 0;
}
