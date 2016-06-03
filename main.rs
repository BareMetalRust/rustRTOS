#![feature(no_std)]
#![feature(core)]
#![feature(lang_items)]
#![no_std]

#![crate_type="staticlib"]

extern {
    fn main_loop();
}

#[lang="eh_personality"] extern fn eh_personality() {}
#[lang="panic_fmt"]
pub fn panic_fmt(_fmt: &core::fmt::Arguments, _file_line: &(&'static str, usize)) -> !
{
    loop { }
}

/* #[no_mangle] */
/* pub unsafe fn __aeabi_unwind_cpp_pr0() -> () */
/* { */
/*     loop {} */
/* } */
#[no_mangle] pub fn main()
{
    unsafe { main_loop() };
}

